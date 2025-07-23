import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const FCM_SERVER_KEY = Deno.env.get('FCM_SERVER_KEY')!; // Set this in your project env

serve(async (req) => {
  try {
    const { message, group_id, channel_id, thread_id, sender_id, recipient_id, type } = await req.json();

    // 1. Get all user_ids to notify except sender
    let userIds: string[] = [];
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const headers = { apikey: supabaseKey, Authorization: `Bearer ${supabaseKey}` };

    if (type === 'group') {
      const res = await fetch(`${supabaseUrl}/rest/v1/group_members?group_id=eq.${group_id}&select=user_id`, { headers });
      userIds = (await res.json()).map((row: any) => row.user_id);
      userIds = userIds.filter((id) => id !== sender_id);
    } else if (type === 'channel') {
      const res = await fetch(`${supabaseUrl}/rest/v1/channel_members?channel_id=eq.${channel_id}&select=user_id`, { headers });
      userIds = (await res.json()).map((row: any) => row.user_id);
      userIds = userIds.filter((id) => id !== sender_id);
    } else if (type === 'thread') {
      // Try thread_members first, fallback to all users who posted in the thread
      let threadMembers: string[] = [];
      const threadMembersRes = await fetch(`${supabaseUrl}/rest/v1/thread_members?thread_id=eq.${thread_id}&select=user_id`, { headers });
      if (threadMembersRes.ok) {
        threadMembers = (await threadMembersRes.json()).map((row: any) => row.user_id);
      }
      if (threadMembers.length === 0) {
        // Fallback: all users who posted in the thread
        const threadMsgsRes = await fetch(`${supabaseUrl}/rest/v1/thread_messages?thread_id=eq.${thread_id}&select=user_id`, { headers });
        threadMembers = Array.from(new Set((await threadMsgsRes.json()).map((row: any) => row.user_id)));
      }
      userIds = threadMembers.filter((id) => id !== sender_id);
    } else if (type === 'dm') {
      // Direct message: notify only the recipient
      if (recipient_id && recipient_id !== sender_id) {
        userIds = [recipient_id];
      }
    }

    if (userIds.length === 0) {
      return new Response(JSON.stringify({ success: true, message: 'No recipients' }), { status: 200 });
    }

    // 2. Get device tokens for these users
    const tokensRes = await fetch(
      `${supabaseUrl}/rest/v1/device_tokens?user_id=in.(${userIds.map((id) => `"${id}"`).join(',')})&select=token`,
      { headers }
    );
    const tokensData = await tokensRes.json();
    const tokens = tokensData.map((row: any) => row.token).filter(Boolean);

    if (tokens.length === 0) {
      return new Response(JSON.stringify({ success: true, message: 'No device tokens' }), { status: 200 });
    }

    // 3. Send FCM notification with deep linking data
    const fcmPayload = {
      registration_ids: tokens,
      notification: {
        title: message.title,
        body: message.body,
      },
      data: message.data || {},
    };

    // Add deep link data for navigation
    if (type === 'group') {
      fcmPayload.data.type = 'group';
      fcmPayload.data.group_id = group_id;
    } else if (type === 'channel') {
      fcmPayload.data.type = 'channel';
      fcmPayload.data.channel_id = channel_id;
    } else if (type === 'thread') {
      fcmPayload.data.type = 'thread';
      fcmPayload.data.thread_id = thread_id;
    } else if (type === 'dm') {
      fcmPayload.data.type = 'dm';
      fcmPayload.data.sender_id = sender_id;
    }

    const fcmRes = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Authorization': `key=${FCM_SERVER_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(fcmPayload),
    });

    const fcmResult = await fcmRes.json();

    return new Response(JSON.stringify({ success: true, fcmResult }), { status: 200 });
  } catch (e) {
    return new Response(JSON.stringify({ success: false, error: e.message }), { status: 500 });
  }
}); 
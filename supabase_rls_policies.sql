-- Row-Level Security (RLS) Policies for InternHub App
-- This script enables RLS and creates policies for all tables

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roommate_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.channels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.channel_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.threads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.thread_messages ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PROFILES POLICIES
-- ============================================

-- Anyone can read profiles (for discovery)
CREATE POLICY "Profiles are viewable by everyone"
ON public.profiles FOR SELECT
TO authenticated
USING (true);

-- Users can only insert their own profile
CREATE POLICY "Users can insert their own profile"
ON public.profiles FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- Users can only update their own profile
CREATE POLICY "Users can update their own profile"
ON public.profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Users can only delete their own profile
CREATE POLICY "Users can delete their own profile"
ON public.profiles FOR DELETE
TO authenticated
USING (auth.uid() = id);

-- ============================================
-- POSTS POLICIES
-- ============================================

-- Anyone can read posts
CREATE POLICY "Posts are viewable by everyone"
ON public.posts FOR SELECT
TO authenticated
USING (true);

-- Users can only insert their own posts
CREATE POLICY "Users can insert their own posts"
ON public.posts FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Users can only update their own posts
CREATE POLICY "Users can update their own posts"
ON public.posts FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can only delete their own posts
CREATE POLICY "Users can delete their own posts"
ON public.posts FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- ============================================
-- MESSAGES POLICIES
-- ============================================

-- Users can only see messages they sent or received
CREATE POLICY "Users can view their messages"
ON public.messages FOR SELECT
TO authenticated
USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

-- Users can only send messages as themselves
CREATE POLICY "Users can send messages"
ON public.messages FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = sender_id);

-- Users can only update messages they sent
CREATE POLICY "Users can update their sent messages"
ON public.messages FOR UPDATE
TO authenticated
USING (auth.uid() = sender_id)
WITH CHECK (auth.uid() = sender_id);

-- Users can only delete messages they sent
CREATE POLICY "Users can delete their sent messages"
ON public.messages FOR DELETE
TO authenticated
USING (auth.uid() = sender_id);

-- ============================================
-- CONNECTIONS POLICIES
-- ============================================

-- Users can view connections where they are follower or following
CREATE POLICY "Users can view their connections"
ON public.connections FOR SELECT
TO authenticated
USING (auth.uid() = follower_id OR auth.uid() = following_id);

-- Users can only create connections as themselves
CREATE POLICY "Users can create connections"
ON public.connections FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = follower_id);

-- Users can only delete their own connections
CREATE POLICY "Users can delete their connections"
ON public.connections FOR DELETE
TO authenticated
USING (auth.uid() = follower_id);

-- ============================================
-- GROUPS POLICIES
-- ============================================

-- Anyone can view groups
CREATE POLICY "Groups are viewable by everyone"
ON public.groups FOR SELECT
TO authenticated
USING (true);

-- Authenticated users can create groups
CREATE POLICY "Users can create groups"
ON public.groups FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = created_by);

-- Only group creator can update
CREATE POLICY "Group creators can update groups"
ON public.groups FOR UPDATE
TO authenticated
USING (auth.uid() = created_by)
WITH CHECK (auth.uid() = created_by);

-- Only group creator can delete
CREATE POLICY "Group creators can delete groups"
ON public.groups FOR DELETE
TO authenticated
USING (auth.uid() = created_by);

-- ============================================
-- GROUP MEMBERS POLICIES
-- ============================================

-- Group members can view membership
CREATE POLICY "Group members can view membership"
ON public.group_members FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.group_members gm
    WHERE gm.group_id = group_members.group_id
    AND gm.user_id = auth.uid()
  )
);

-- Users can join groups
CREATE POLICY "Users can join groups"
ON public.group_members FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Users can leave groups (delete their membership)
CREATE POLICY "Users can leave groups"
ON public.group_members FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- ============================================
-- GROUP MESSAGES POLICIES
-- ============================================

-- Group members can view messages
CREATE POLICY "Group members can view messages"
ON public.group_messages FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.group_members gm
    WHERE gm.group_id = group_messages.group_id
    AND gm.user_id = auth.uid()
  )
);

-- Group members can send messages
CREATE POLICY "Group members can send messages"
ON public.group_messages FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = user_id AND
  EXISTS (
    SELECT 1 FROM public.group_members gm
    WHERE gm.group_id = group_messages.group_id
    AND gm.user_id = auth.uid()
  )
);

-- Users can update their own messages
CREATE POLICY "Users can update their group messages"
ON public.group_messages FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own messages
CREATE POLICY "Users can delete their group messages"
ON public.group_messages FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- ============================================
-- ROOMMATE PROFILES POLICIES
-- ============================================

-- Anyone can view roommate profiles
CREATE POLICY "Roommate profiles are viewable by everyone"
ON public.roommate_profiles FOR SELECT
TO authenticated
USING (true);

-- Users can only create their own roommate profile
CREATE POLICY "Users can create their own roommate profile"
ON public.roommate_profiles FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Users can only update their own roommate profile
CREATE POLICY "Users can update their own roommate profile"
ON public.roommate_profiles FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can only delete their own roommate profile
CREATE POLICY "Users can delete their own roommate profile"
ON public.roommate_profiles FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- ============================================
-- CHANNELS POLICIES
-- ============================================

-- Anyone can view channels
CREATE POLICY "Channels are viewable by everyone"
ON public.channels FOR SELECT
TO authenticated
USING (true);

-- Authenticated users can create channels
CREATE POLICY "Users can create channels"
ON public.channels FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = created_by);

-- Channel creators can update
CREATE POLICY "Channel creators can update channels"
ON public.channels FOR UPDATE
TO authenticated
USING (auth.uid() = created_by)
WITH CHECK (auth.uid() = created_by);

-- Channel creators can delete
CREATE POLICY "Channel creators can delete channels"
ON public.channels FOR DELETE
TO authenticated
USING (auth.uid() = created_by);

-- ============================================
-- CHANNEL MESSAGES POLICIES
-- ============================================

-- Anyone can view channel messages
CREATE POLICY "Channel messages are viewable by everyone"
ON public.channel_messages FOR SELECT
TO authenticated
USING (true);

-- Authenticated users can send channel messages
CREATE POLICY "Users can send channel messages"
ON public.channel_messages FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Users can update their own messages
CREATE POLICY "Users can update their channel messages"
ON public.channel_messages FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own messages
CREATE POLICY "Users can delete their channel messages"
ON public.channel_messages FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- ============================================
-- THREADS POLICIES
-- ============================================

-- Anyone can view threads
CREATE POLICY "Threads are viewable by everyone"
ON public.threads FOR SELECT
TO authenticated
USING (true);

-- Authenticated users can create threads
CREATE POLICY "Users can create threads"
ON public.threads FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = created_by);

-- Thread creators can update
CREATE POLICY "Thread creators can update threads"
ON public.threads FOR UPDATE
TO authenticated
USING (auth.uid() = created_by)
WITH CHECK (auth.uid() = created_by);

-- Thread creators can delete
CREATE POLICY "Thread creators can delete threads"
ON public.threads FOR DELETE
TO authenticated
USING (auth.uid() = created_by);

-- ============================================
-- THREAD MESSAGES POLICIES
-- ============================================

-- Anyone can view thread messages
CREATE POLICY "Thread messages are viewable by everyone"
ON public.thread_messages FOR SELECT
TO authenticated
USING (true);

-- Authenticated users can send thread messages
CREATE POLICY "Users can send thread messages"
ON public.thread_messages FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Users can update their own messages
CREATE POLICY "Users can update their thread messages"
ON public.thread_messages FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own messages
CREATE POLICY "Users can delete their thread messages"
ON public.thread_messages FOR DELETE
TO authenticated
USING (auth.uid() = user_id);


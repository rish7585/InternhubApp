-- Database Indexes for Performance Optimization
-- These indexes improve query performance for common operations

-- ============================================
-- POSTS INDEXES
-- ============================================

-- Index for fetching posts by user (profile feed)
CREATE INDEX IF NOT EXISTS idx_posts_user_id 
ON public.posts(user_id);

-- Index for fetching posts by creation date (feed ordering)
CREATE INDEX IF NOT EXISTS idx_posts_created_at 
ON public.posts(created_at DESC);

-- Composite index for user feed queries
CREATE INDEX IF NOT EXISTS idx_posts_user_created 
ON public.posts(user_id, created_at DESC);

-- ============================================
-- MESSAGES INDEXES
-- ============================================

-- Index for fetching messages by sender
CREATE INDEX IF NOT EXISTS idx_messages_sender 
ON public.messages(sender_id);

-- Index for fetching messages by receiver
CREATE INDEX IF NOT EXISTS idx_messages_receiver 
ON public.messages(receiver_id);

-- Index for fetching messages by creation date
CREATE INDEX IF NOT EXISTS idx_messages_created_at 
ON public.messages(created_at DESC);

-- Composite index for conversation queries
CREATE INDEX IF NOT EXISTS idx_messages_conversation 
ON public.messages(sender_id, receiver_id, created_at DESC);

-- ============================================
-- CONNECTIONS INDEXES
-- ============================================

-- Index for finding who a user follows
CREATE INDEX IF NOT EXISTS idx_connections_follower 
ON public.connections(follower_id);

-- Index for finding who follows a user
CREATE INDEX IF NOT EXISTS idx_connections_following 
ON public.connections(following_id);

-- Composite index for checking if connection exists
CREATE INDEX IF NOT EXISTS idx_connections_pair 
ON public.connections(follower_id, following_id);

-- ============================================
-- GROUPS INDEXES
-- ============================================

-- Index for finding groups by creator
CREATE INDEX IF NOT EXISTS idx_groups_created_by 
ON public.groups(created_by);

-- Index for finding groups by creation date
CREATE INDEX IF NOT EXISTS idx_groups_created_at 
ON public.groups(created_at DESC);

-- ============================================
-- GROUP MEMBERS INDEXES
-- ============================================

-- Index for finding groups a user belongs to
CREATE INDEX IF NOT EXISTS idx_group_members_user 
ON public.group_members(user_id);

-- Index for finding members of a group
CREATE INDEX IF NOT EXISTS idx_group_members_group 
ON public.group_members(group_id);

-- Composite index for checking membership
CREATE INDEX IF NOT EXISTS idx_group_members_pair 
ON public.group_members(group_id, user_id);

-- ============================================
-- GROUP MESSAGES INDEXES
-- ============================================

-- Index for fetching messages by group
CREATE INDEX IF NOT EXISTS idx_group_messages_group 
ON public.group_messages(group_id);

-- Index for fetching messages by user
CREATE INDEX IF NOT EXISTS idx_group_messages_user 
ON public.group_messages(user_id);

-- Index for fetching messages by creation date
CREATE INDEX IF NOT EXISTS idx_group_messages_created 
ON public.group_messages(created_at DESC);

-- Composite index for group message queries
CREATE INDEX IF NOT EXISTS idx_group_messages_group_created 
ON public.group_messages(group_id, created_at DESC);

-- ============================================
-- ROOMMATE PROFILES INDEXES
-- ============================================

-- Index for finding roommate profiles by user
CREATE INDEX IF NOT EXISTS idx_roommate_profiles_user 
ON public.roommate_profiles(user_id);

-- Index for finding roommate profiles by location
CREATE INDEX IF NOT EXISTS idx_roommate_profiles_location 
ON public.roommate_profiles(location);

-- Index for finding roommate profiles by budget range
CREATE INDEX IF NOT EXISTS idx_roommate_profiles_budget 
ON public.roommate_profiles(budget);

-- Index for location-based queries (if using PostGIS)
-- CREATE INDEX IF NOT EXISTS idx_roommate_profiles_location_gist 
-- ON public.roommate_profiles USING GIST (ll_to_earth(latitude, longitude));

-- Composite index for location and budget filtering
CREATE INDEX IF NOT EXISTS idx_roommate_profiles_location_budget 
ON public.roommate_profiles(location, budget);

-- ============================================
-- CHANNELS INDEXES
-- ============================================

-- Index for finding channels by creator
CREATE INDEX IF NOT EXISTS idx_channels_created_by 
ON public.channels(created_by);

-- Index for finding channels by creation date
CREATE INDEX IF NOT EXISTS idx_channels_created_at 
ON public.channels(created_at DESC);

-- ============================================
-- CHANNEL MESSAGES INDEXES
-- ============================================

-- Index for fetching messages by channel
CREATE INDEX IF NOT EXISTS idx_channel_messages_channel 
ON public.channel_messages(channel_id);

-- Index for fetching messages by user
CREATE INDEX IF NOT EXISTS idx_channel_messages_user 
ON public.channel_messages(user_id);

-- Index for fetching messages by creation date
CREATE INDEX IF NOT EXISTS idx_channel_messages_created 
ON public.channel_messages(created_at DESC);

-- Composite index for channel message queries
CREATE INDEX IF NOT EXISTS idx_channel_messages_channel_created 
ON public.channel_messages(channel_id, created_at DESC);

-- ============================================
-- THREADS INDEXES
-- ============================================

-- Index for finding threads by channel
CREATE INDEX IF NOT EXISTS idx_threads_channel 
ON public.threads(channel_id);

-- Index for finding threads by creator
CREATE INDEX IF NOT EXISTS idx_threads_created_by 
ON public.threads(created_by);

-- Index for finding threads by creation date
CREATE INDEX IF NOT EXISTS idx_threads_created_at 
ON public.threads(created_at DESC);

-- ============================================
-- THREAD MESSAGES INDEXES
-- ============================================

-- Index for fetching messages by thread
CREATE INDEX IF NOT EXISTS idx_thread_messages_thread 
ON public.thread_messages(thread_id);

-- Index for fetching messages by user
CREATE INDEX IF NOT EXISTS idx_thread_messages_user 
ON public.thread_messages(user_id);

-- Index for fetching messages by creation date
CREATE INDEX IF NOT EXISTS idx_thread_messages_created 
ON public.thread_messages(created_at DESC);

-- Composite index for thread message queries
CREATE INDEX IF NOT EXISTS idx_thread_messages_thread_created 
ON public.thread_messages(thread_id, created_at DESC);

-- ============================================
-- PROFILES INDEXES
-- ============================================

-- Index for finding profiles by user (already exists, but ensuring it)
CREATE INDEX IF NOT EXISTS idx_profiles_user_id 
ON public.profiles(id);

-- Index for searching profiles by name
CREATE INDEX IF NOT EXISTS idx_profiles_name_search 
ON public.profiles USING gin(to_tsvector('english', first_name || ' ' || last_name));

-- Index for finding profiles by location
CREATE INDEX IF NOT EXISTS idx_profiles_location 
ON public.profiles(location);

-- Index for finding profiles by company
CREATE INDEX IF NOT EXISTS idx_profiles_company 
ON public.profiles(company);


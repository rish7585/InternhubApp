-- Database Restore Script for Supabase
-- Generated from backup: db_cluster-08-08-2025@01-55-45.backup
--
-- IMPORTANT: This script will DROP existing tables if they exist.
-- Make sure to backup your current database before running this script.

BEGIN;

-- Drop table if exists
DROP TABLE IF EXISTS public.channel_message_reads CASCADE;

CREATE TABLE public.channel_message_reads (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    user_id uuid,
    channel_id uuid,
    last_read_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Drop table if exists
DROP TABLE IF EXISTS public.channel_messages CASCADE;

CREATE TABLE public.channel_messages (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    channel_id uuid,
    user_id uuid,
    content text,
    type text DEFAULT 'text'::text,
    created_at timestamp with time zone DEFAULT now()
);

-- Drop table if exists
DROP TABLE IF EXISTS public.channels CASCADE;

CREATE TABLE public.channels (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    description text,
    city text,
    interest text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now()
);

-- Drop table if exists
DROP TABLE IF EXISTS public.comments CASCADE;

CREATE TABLE public.comments (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    post_id uuid NOT NULL,
    user_id uuid NOT NULL,
    content text NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Drop table if exists
DROP TABLE IF EXISTS public.connections CASCADE;

CREATE TABLE public.connections (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    follower_id uuid NOT NULL,
    following_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Drop table if exists
DROP TABLE IF EXISTS public.device_tokens CASCADE;

CREATE TABLE public.device_tokens (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    user_id uuid,
    token text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Drop table if exists
DROP TABLE IF EXISTS public.group_invites CASCADE;

CREATE TABLE public.group_invites (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    group_id uuid NOT NULL,
    invited_user_id uuid NOT NULL,
    invited_by_user_id uuid NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    message text,
    created_at timestamp with time zone DEFAULT now(),
    responded_at timestamp with time zone,
    CONSTRAINT group_invites_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'accepted'::text, 'declined'::text])))
);

-- Drop table if exists
DROP TABLE IF EXISTS public.groups CASCADE;

CREATE TABLE public.groups (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    description text,
    city text,
    company text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now()
);

-- Drop table if exists
DROP TABLE IF EXISTS public.profiles CASCADE;

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    email text NOT NULL,
    phone text NOT NULL,
    bio text,
    company text NOT NULL,
    location text NOT NULL,
    profile_picture_url text,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    user_id uuid,
    avatar_url text
);

-- Drop table if exists
DROP TABLE IF EXISTS public.group_members CASCADE;

CREATE TABLE public.group_members (
    group_id uuid NOT NULL,
    user_id uuid NOT NULL,
    joined_at timestamp with time zone DEFAULT now(),
    role text DEFAULT 'member'::text
);

-- Drop table if exists
DROP TABLE IF EXISTS public.group_message_reads CASCADE;

CREATE TABLE public.group_message_reads (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    user_id uuid,
    group_id uuid,
    last_read_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Drop table if exists
DROP TABLE IF EXISTS public.group_messages CASCADE;

CREATE TABLE public.group_messages (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    group_id uuid,
    user_id uuid,
    content text,
    type text DEFAULT 'text'::text,
    created_at timestamp with time zone DEFAULT now(),
    reply_to_message_id uuid,
    pinned boolean DEFAULT false
);

-- Drop table if exists
DROP TABLE IF EXISTS public.likes CASCADE;

CREATE TABLE public.likes (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    post_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Drop table if exists
DROP TABLE IF EXISTS public.message_reactions CASCADE;

CREATE TABLE public.message_reactions (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    message_id uuid NOT NULL,
    user_id uuid NOT NULL,
    reaction text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);

-- Drop table if exists
DROP TABLE IF EXISTS public.message_reads CASCADE;

CREATE TABLE public.message_reads (
    message_id uuid NOT NULL,
    user_id uuid NOT NULL,
    read_at timestamp with time zone DEFAULT now()
);

-- Drop table if exists
DROP TABLE IF EXISTS public.message_replies CASCADE;

CREATE TABLE public.message_replies (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    message_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    receiver_id uuid NOT NULL,
    content text NOT NULL,
    image_url text,
    is_read boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Drop table if exists
DROP TABLE IF EXISTS public.messages CASCADE;

CREATE TABLE public.messages (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    sender_id uuid,
    receiver_id uuid,
    content text NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Drop table if exists
DROP TABLE IF EXISTS public.notifications CASCADE;

CREATE TABLE public.notifications (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    actor_id uuid NOT NULL,
    type text NOT NULL,
    reference_id uuid,
    is_read boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Drop table if exists
DROP TABLE IF EXISTS public.posts CASCADE;

CREATE TABLE public.posts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    content text NOT NULL,
    image_url text,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Drop table if exists
DROP TABLE IF EXISTS public.roommate_profiles CASCADE;

CREATE TABLE public.roommate_profiles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    name text NOT NULL,
    phone text NOT NULL,
    school text NOT NULL,
    company text NOT NULL,
    desired_building text NOT NULL,
    location text NOT NULL,
    budget numeric(10,2) NOT NULL,
    lease_duration text NOT NULL,
    roommate_preferences text[] DEFAULT '{}'::text[] NOT NULL,
    social_link text,
    personal_bio text NOT NULL,
    interests text[] DEFAULT '{}'::text[] NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Drop table if exists
DROP TABLE IF EXISTS public.thread_messages CASCADE;

CREATE TABLE public.thread_messages (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    thread_id uuid,
    user_id uuid,
    content text,
    type text DEFAULT 'text'::text,
    created_at timestamp with time zone DEFAULT now()
);

-- Drop table if exists
DROP TABLE IF EXISTS public.threads CASCADE;

CREATE TABLE public.threads (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    channel_id uuid,
    title text NOT NULL,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now()
);

-- Drop table if exists
DROP TABLE IF EXISTS public.user_presence CASCADE;

CREATE TABLE public.user_presence (
    user_id uuid NOT NULL,
    chat_id uuid NOT NULL,
    is_typing boolean DEFAULT false,
    last_active timestamp with time zone DEFAULT now()
);

-- Drop table if exists
DROP TABLE IF EXISTS public.users CASCADE;

CREATE TABLE public.users (
    id uuid NOT NULL,
    email text NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

DROP VIEW IF EXISTS public.group_invites_with_details CASCADE;
CREATE VIEW public.group_invites_with_details AS
 SELECT gi.id,
    gi.group_id,
    gi.invited_user_id,
    gi.invited_by_user_id,
    gi.status,
    gi.message,
    gi.created_at,
    gi.responded_at,
    g.name AS group_name,
    g.description AS group_description,
    inviter.first_name AS inviter_first_name,
    inviter.last_name AS inviter_last_name,
    COALESCE(inviter.avatar_url, ''::text) AS inviter_avatar_url,
    invited.first_name AS invited_first_name,
    invited.last_name AS invited_last_name,
    COALESCE(invited.avatar_url, ''::text) AS invited_avatar_url
   FROM (((public.group_invites gi
     JOIN public.groups g ON ((gi.group_id = g.id)))
     JOIN public.profiles inviter ON ((gi.invited_by_user_id = inviter.id)))
     JOIN public.profiles invited ON ((gi.invited_user_id = invited.id)));

ALTER TABLE ONLY public.channel_message_reads
    ADD CONSTRAINT channel_message_reads_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.channel_message_reads
    ADD CONSTRAINT channel_message_reads_user_id_channel_id_key UNIQUE (user_id, channel_id);

ALTER TABLE ONLY public.channel_messages
    ADD CONSTRAINT channel_messages_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.connections
    ADD CONSTRAINT connections_follower_id_following_id_key UNIQUE (follower_id, following_id);

ALTER TABLE ONLY public.connections
    ADD CONSTRAINT connections_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.connections
    ADD CONSTRAINT connections_unique_follow UNIQUE (follower_id, following_id);

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_token_key UNIQUE (token);

ALTER TABLE ONLY public.group_invites
    ADD CONSTRAINT group_invites_group_id_invited_user_id_status_key UNIQUE (group_id, invited_user_id, status);

ALTER TABLE ONLY public.group_invites
    ADD CONSTRAINT group_invites_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_pkey PRIMARY KEY (group_id, user_id);

ALTER TABLE ONLY public.group_message_reads
    ADD CONSTRAINT group_message_reads_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.group_message_reads
    ADD CONSTRAINT group_message_reads_user_id_group_id_key UNIQUE (user_id, group_id);

ALTER TABLE ONLY public.group_messages
    ADD CONSTRAINT group_messages_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_post_id_user_id_key UNIQUE (post_id, user_id);

ALTER TABLE ONLY public.message_reactions
    ADD CONSTRAINT message_reactions_message_id_user_id_reaction_key UNIQUE (message_id, user_id, reaction);

ALTER TABLE ONLY public.message_reactions
    ADD CONSTRAINT message_reactions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.message_reads
    ADD CONSTRAINT message_reads_pkey PRIMARY KEY (message_id, user_id);

ALTER TABLE ONLY public.message_replies
    ADD CONSTRAINT message_replies_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_key UNIQUE (user_id);

ALTER TABLE ONLY public.roommate_profiles
    ADD CONSTRAINT roommate_profiles_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.thread_messages
    ADD CONSTRAINT thread_messages_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.threads
    ADD CONSTRAINT threads_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.user_presence
    ADD CONSTRAINT user_presence_pkey PRIMARY KEY (user_id, chat_id);

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.channel_message_reads
    ADD CONSTRAINT channel_message_reads_channel_id_fkey FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.channel_message_reads
    ADD CONSTRAINT channel_message_reads_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.channel_messages
    ADD CONSTRAINT channel_messages_channel_id_fkey FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.channel_messages
    ADD CONSTRAINT channel_messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id);

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id);

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);

ALTER TABLE ONLY public.connections
    ADD CONSTRAINT connections_follower_id_fkey FOREIGN KEY (follower_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.connections
    ADD CONSTRAINT connections_following_id_fkey FOREIGN KEY (following_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.group_invites
    ADD CONSTRAINT group_invites_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.group_invites
    ADD CONSTRAINT group_invites_invited_by_user_id_fkey FOREIGN KEY (invited_by_user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.group_invites
    ADD CONSTRAINT group_invites_invited_user_id_fkey FOREIGN KEY (invited_user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.group_message_reads
    ADD CONSTRAINT group_message_reads_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.group_message_reads
    ADD CONSTRAINT group_message_reads_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.group_messages
    ADD CONSTRAINT group_messages_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.group_messages
    ADD CONSTRAINT group_messages_reply_to_message_id_fkey FOREIGN KEY (reply_to_message_id) REFERENCES public.group_messages(id);

ALTER TABLE ONLY public.group_messages
    ADD CONSTRAINT group_messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id);

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id);

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);

ALTER TABLE ONLY public.message_reads
    ADD CONSTRAINT message_reads_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.group_messages(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.message_reads
    ADD CONSTRAINT message_reads_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.message_replies
    ADD CONSTRAINT message_replies_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.messages(id);

ALTER TABLE ONLY public.message_replies
    ADD CONSTRAINT message_replies_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.users(id);

ALTER TABLE ONLY public.message_replies
    ADD CONSTRAINT message_replies_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id);

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.users(id);

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.roommate_profiles
    ADD CONSTRAINT roommate_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.thread_messages
    ADD CONSTRAINT thread_messages_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES public.threads(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.thread_messages
    ADD CONSTRAINT thread_messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.threads
    ADD CONSTRAINT threads_channel_id_fkey FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.threads
    ADD CONSTRAINT threads_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id);

ALTER TABLE ONLY public.user_presence
    ADD CONSTRAINT user_presence_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id);

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: idx_connections_follower_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_connections_follower_id ON public.connections USING btree (follower_id);

CREATE INDEX idx_connections_following_id ON public.connections USING btree (following_id);

CREATE INDEX idx_connections_unique_follow ON public.connections USING btree (follower_id, following_id);

CREATE INDEX idx_group_invites_created_at ON public.group_invites USING btree (created_at);

CREATE INDEX idx_group_invites_group_id ON public.group_invites USING btree (group_id);

CREATE INDEX idx_group_invites_invited_user_id ON public.group_invites USING btree (invited_user_id);

CREATE INDEX idx_group_invites_status ON public.group_invites USING btree (status);

CREATE INDEX idx_roommate_profiles_budget ON public.roommate_profiles USING btree (budget);

CREATE INDEX idx_roommate_profiles_location ON public.roommate_profiles USING btree (location);

CREATE INDEX idx_roommate_profiles_user_id ON public.roommate_profiles USING btree (user_id);

CREATE INDEX message_replies_created_at_idx ON public.message_replies USING btree (created_at);

CREATE INDEX message_replies_message_id_idx ON public.message_replies USING btree (message_id);

CREATE INDEX message_replies_receiver_id_idx ON public.message_replies USING btree (receiver_id);

CREATE INDEX message_replies_sender_id_idx ON public.message_replies USING btree (sender_id);

CREATE INDEX messages_created_at_idx ON public.messages USING btree (created_at);

CREATE INDEX messages_receiver_id_idx ON public.messages USING btree (receiver_id);

CREATE INDEX messages_sender_id_idx ON public.messages USING btree (sender_id);

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: messages_2025_07_29_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_07_29_pkey;


--
-- Name: messages_2025_07_30_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_07_30_pkey;


--
-- Name: messages_2025_07_31_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_07_31_pkey;


--
-- Name: messages_2025_08_01_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_08_01_pkey;


--
-- Name: messages_2025_08_02_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_08_02_pkey;


--
-- Name: messages_2025_08_03_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_08_03_pkey;


--
-- Name: messages_2025_08_04_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_08_04_pkey;


--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: supabase_auth_admin
--

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Insert data into public.connections
INSERT INTO public.connections (id, follower_id, following_id, created_at) VALUES
('1e027aa8-c1c5-4820-9610-4a7b725bc3c5', 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', 'aae22064-f59c-4de2-9655-15a7bc501e59', '2025-07-03 22:51:32.64899+00'),
('0d22188c-d130-48de-99ee-17fdf99be8d6', 'aae22064-f59c-4de2-9655-15a7bc501e59', 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', '2025-07-03 22:52:43.801082+00');

-- Insert data into public.group_members
INSERT INTO public.group_members (group_id, user_id, joined_at, role) VALUES
('3f6d7f67-4073-401d-ad6f-3f2200e610ea', 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', '2025-07-27 14:17:16.403+00', 'admin');

-- Insert data into public.group_message_reads
INSERT INTO public.group_message_reads (id, user_id, group_id, last_read_at) VALUES
('a5400fe3-235a-494e-bbfa-57b6ea5b96f8', 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', '3f6d7f67-4073-401d-ad6f-3f2200e610ea', '2025-07-27 14:17:18.428+00');

-- Insert data into public.groups
INSERT INTO public.groups (id, name, description, city, company, created_by, created_at) VALUES
('098286a4-dc95-42ce-afcb-f61326be93d3', 'hj', 'j', NULL, NULL, 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', '2025-07-27 18:13:35.718637+00'),
('daa8d9c8-5927-4c1a-bcf1-066eb3377f4b', 'jhkaskjhfd', 'jkhfjkas', NULL, NULL, 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', '2025-07-27 18:13:40.855353+00'),
('cf78a0f4-53bc-43d8-94bb-ae76abae4fe7', 'Trial Group', 'For internhub trial purposes', NULL, NULL, 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', '2025-07-27 18:15:49.496761+00'),
('3f6d7f67-4073-401d-ad6f-3f2200e610ea', 'Internhub Trial run', 'Trial purposes', NULL, NULL, 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', '2025-07-27 18:17:16.361424+00');

-- Insert data into public.messages
INSERT INTO public.messages (id, sender_id, receiver_id, content, created_at, updated_at) VALUES
('0d862432-221d-404b-8592-c3f7a2ea3426', 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', 'aae22064-f59c-4de2-9655-15a7bc501e59', 'hi', '2025-06-04 19:28:24.148+00', '2025-06-04 19:28:24.289788+00'),
('5c444b25-2ce5-44f5-a555-2b5d3b151585', 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', 'aae22064-f59c-4de2-9655-15a7bc501e59', 'how has your day been', '2025-06-04 19:29:16.775+00', '2025-06-04 19:29:16.967639+00'),
('0ff8882d-5141-4b64-9eaf-39500c2bfc52', 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', 'aae22064-f59c-4de2-9655-15a7bc501e59', 'whats happening', '2025-06-04 19:29:25.982+00', '2025-06-04 19:29:26.049495+00'),
('4a9c6e3a-3819-4663-9585-6a5417011bc2', 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', 'aae22064-f59c-4de2-9655-15a7bc501e59', 'hi', '2025-06-05 01:19:02.957+00', '2025-06-05 01:19:03.092128+00'),
('a7044ee2-6914-43b2-87bf-cfaee671dd36', 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', 'aae22064-f59c-4de2-9655-15a7bc501e59', 'hi', '2025-07-04 00:14:42.322+00', '2025-07-04 00:14:42.489748+00'),
('a1338850-cdd0-4f0a-816f-e30502dc9781', 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', 'aae22064-f59c-4de2-9655-15a7bc501e59', 'hi', '2025-07-15 20:54:39.870572+00', '2025-07-15 20:54:39.998106+00'),
('d2496971-e943-40f3-bea8-455a0a08974f', 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', 'aae22064-f59c-4de2-9655-15a7bc501e59', '🤪🤤🥲', '2025-08-01 00:03:04.77171+00', '2025-08-01 00:03:05.155793+00'),
('cd69fd10-d85f-4fc2-9e63-56abbff95f7b', 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', 'aae22064-f59c-4de2-9655-15a7bc501e59', '🤪🤤🥲', '2025-08-01 00:03:05.738754+00', '2025-08-01 00:03:05.875326+00'),
('576f7f57-62ba-4746-8b94-505cee5faaeb', 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', 'aae22064-f59c-4de2-9655-15a7bc501e59', '🤪🤤🥲', '2025-08-01 00:03:06.613726+00', '2025-08-01 00:03:06.773607+00');

-- Insert data into public.posts
INSERT INTO public.posts (id, user_id, content, image_url, created_at) VALUES
('3ceaafc1-a748-4ba4-b74b-a49875fd1347', 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', 'you guys like my profile picture????', 'https://rvdquolhgpnywssgsmhr.supabase.co/storage/v1/object/public/profile-pic/post_images/e9680c82-3911-4b4a-a6fa-e0c8aff8fb77_1748891166280.jpg', '2025-06-02 15:06:06.645+00'),
('04e13aa3-4f50-49ad-9ab5-b91cbcd30861', 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', 'The', NULL, '2025-07-09 19:29:44.557133+00'),
('11a7314b-6fb5-4c4a-9ad2-8b60bcc7dc5b', 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', 'JJ', NULL, '2025-07-09 19:30:07.520023+00'),
('5611a0e6-97b4-4fb6-84aa-1df3fda5cf0b', 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', 'hi', NULL, '2025-07-15 16:54:51.595389+00');

-- Insert data into public.profiles
INSERT INTO public.profiles (id, first_name, last_name, email, phone, bio, company, location, profile_picture_url, created_at, updated_at, user_id, avatar_url) VALUES
('e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', 'Rishvin', 'Jasti', 'rish7585@gmail.com', '6787486447', 'I am 6''7 hooper, hoping to make it to the nba one day. Currently the co-founder of internhub, looking forward to meeting everyone.', 'InternHub', 'Atlanta', 'https://rvdquolhgpnywssgsmhr.supabase.co/storage/v1/object/public/profile-pic/profile_pictures/e9680c82-3911-4b4a-a6fa-e0c8aff8fb77.jpg', '2025-06-01 15:47:52.115+00', '2025-06-01 15:47:52.116+00', 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', NULL),
('aae22064-f59c-4de2-9655-15a7bc501e59', 'Intern', 'HUb', 'rishvin.jasti@gmail.com', '6787486447', NULL, 'Internhub', 'Atlanta', NULL, '2025-06-04 15:07:20.405+00', '2025-06-04 15:07:20.405+00', 'aae22064-f59c-4de2-9655-15a7bc501e59', NULL);

-- Insert data into public.roommate_profiles
INSERT INTO public.roommate_profiles (id, user_id, name, phone, school, company, desired_building, location, budget, lease_duration, roommate_preferences, social_link, personal_bio, interests, created_at, updated_at) VALUES
('94992453-e0b9-42b9-bed3-bd65960b7422', 'e9680c82-3911-4b4a-a6fa-e0c8aff8fb77', 'Rishvin jasti', '6787486447', 'University of Georgia', 'Google', 'Mark', 'Atlanta', '1500.00', '12 months', '{Professional,Student,"Early riser"}', 'jhjkh', 'ijihihh', '{Cooking,Travel,Fitness}', '2025-07-03 20:29:57.507+00', '2025-07-03 20:29:57.507+00');

COMMIT;

-- Create the profile-pic storage bucket
-- This script creates the bucket and sets up policies for authenticated users

-- Insert the bucket into storage.buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'profile-pic',
  'profile-pic',
  true, -- Make it public so profile pictures can be accessed
  5242880, -- 5MB file size limit
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp'] -- Allowed image types
)
ON CONFLICT (id) DO NOTHING;

-- Create policy to allow authenticated users to upload files
CREATE POLICY "Allow authenticated users to upload profile pictures"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profile-pic' AND
  (storage.foldername(name))[1] = 'profile_pictures'
);

-- Create policy to allow authenticated users to update their own profile pictures
CREATE POLICY "Allow users to update their own profile pictures"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'profile-pic' AND
  (storage.foldername(name))[1] = 'profile_pictures'
)
WITH CHECK (
  bucket_id = 'profile-pic' AND
  (storage.foldername(name))[1] = 'profile_pictures'
);

-- Create policy to allow authenticated users to delete their own profile pictures
CREATE POLICY "Allow users to delete their own profile pictures"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'profile-pic' AND
  (storage.foldername(name))[1] = 'profile_pictures'
);

-- Create policy to allow public read access (since bucket is public)
CREATE POLICY "Allow public read access to profile pictures"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'profile-pic');


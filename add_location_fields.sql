-- Add latitude and longitude columns to roommate_profiles table
-- This enables map-based roommate finding

ALTER TABLE public.roommate_profiles 
ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;

-- Create index for location-based queries
CREATE INDEX IF NOT EXISTS idx_roommate_profiles_location 
ON public.roommate_profiles USING GIST (
  ll_to_earth(latitude, longitude)
);

-- Add comment explaining the columns
COMMENT ON COLUMN public.roommate_profiles.latitude IS 'Latitude coordinate for map display';
COMMENT ON COLUMN public.roommate_profiles.longitude IS 'Longitude coordinate for map display';


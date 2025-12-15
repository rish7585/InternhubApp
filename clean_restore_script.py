#!/usr/bin/env python3
"""
Clean the restore script to remove auth, realtime, and storage schema operations
"""

input_file = '/Users/rishvinjasti/InternhubApp-5/restore_database.sql'
output_file = '/Users/rishvinjasti/InternhubApp-5/restore_database_clean.sql'

with open(input_file, 'r', encoding='utf-8') as f:
    lines = f.readlines()

cleaned_lines = []
skip_until_newline = False

for i, line in enumerate(lines):
    # Skip lines that reference auth, realtime, or storage schemas (except foreign keys to auth.users)
    if any(schema in line.lower() for schema in ['auth.', 'realtime.', 'storage.']):
        # Keep foreign key constraints that reference auth.users (they're needed)
        if 'ADD CONSTRAINT' in line and 'REFERENCES auth.users' in line:
            cleaned_lines.append(line)
        # Skip everything else related to auth, realtime, storage
        continue
    
    # Skip COMMENT statements on auth schema
    if 'COMMENT ON' in line and 'auth.' in line:
        continue
    
    # Skip CREATE TRIGGER on auth schema
    if 'CREATE TRIGGER' in line and 'auth.' in line:
        continue
    
    # Skip ALTER INDEX on auth/realtime/storage
    if 'ALTER INDEX' in line and any(schema in line for schema in ['auth.', 'realtime.', 'storage.']):
        continue
    
    cleaned_lines.append(line)

# Write cleaned script
with open(output_file, 'w', encoding='utf-8') as f:
    f.writelines(cleaned_lines)

print(f"✅ Cleaned script created: {output_file}")
print(f"   Original lines: {len(lines)}")
print(f"   Cleaned lines: {len(cleaned_lines)}")
print(f"   Removed: {len(lines) - len(cleaned_lines)} lines")


#!/usr/bin/env python3
"""
Extract public schema tables, constraints, and data from PostgreSQL backup
and create a SQL script suitable for Supabase SQL Editor
"""

import re
import sys

backup_file = '/Users/rishvinjasti/Downloads/db_cluster-08-08-2025@01-55-45.backup'
output_file = '/Users/rishvinjasti/InternhubApp-5/restore_database.sql'

# Read the backup file
print("Reading backup file...")
with open(backup_file, 'r', encoding='utf-8') as f:
    content = f.read()

sql_script = []
sql_script.append("-- Database Restore Script for Supabase")
sql_script.append("-- Generated from backup: db_cluster-08-08-2025@01-55-45.backup")
sql_script.append("--")
sql_script.append("-- IMPORTANT: This script will DROP existing tables if they exist.")
sql_script.append("-- Make sure to backup your current database before running this script.")
sql_script.append("")
sql_script.append("BEGIN;")
sql_script.append("")

# Extract and add table definitions
print("Extracting table definitions...")
table_section = re.search(r'-- Name: channel_message_reads.*?(?=-- Data for Name:)', content, re.DOTALL)
if table_section:
    # Extract all CREATE TABLE statements for public schema
    create_table_pattern = r'(CREATE TABLE public\.\w+.*?\);)\s*(?:ALTER TABLE.*?OWNER.*?;)?'
    tables = re.findall(create_table_pattern, content, re.DOTALL)
    
    for table_def in tables:
        # Clean up the table definition
        table_def_clean = table_def[0] if isinstance(table_def, tuple) else table_def
        # Remove OWNER clauses as Supabase manages this
        table_def_clean = re.sub(r'\s*ALTER TABLE.*?OWNER.*?;', '', table_def_clean, flags=re.DOTALL)
        sql_script.append("-- Drop table if exists")
        table_name_match = re.search(r'CREATE TABLE public\.(\w+)', table_def_clean)
        if table_name_match:
            table_name = table_name_match.group(1)
            sql_script.append(f"DROP TABLE IF EXISTS public.{table_name} CASCADE;")
        sql_script.append("")
        sql_script.append(table_def_clean)
        sql_script.append("")

# Extract views
print("Extracting views...")
view_pattern = r'CREATE VIEW public\.(\w+) AS(.*?);'
views = re.findall(view_pattern, content, re.DOTALL | re.IGNORECASE)
for view_name, view_def in views:
    sql_script.append(f"DROP VIEW IF EXISTS public.{view_name} CASCADE;")
    sql_script.append(f"CREATE VIEW public.{view_name} AS{view_def};")
    sql_script.append("")

# Extract constraints, primary keys, foreign keys
print("Extracting constraints and keys...")
# Get all ALTER TABLE statements for public schema constraints
constraint_pattern = r'ALTER TABLE (?:ONLY )?public\.(\w+)\s+(ADD CONSTRAINT|ADD PRIMARY KEY|ADD FOREIGN KEY).*?;'
constraints = re.findall(constraint_pattern, content, re.DOTALL | re.IGNORECASE)

constraint_statements = []
for match in re.finditer(constraint_pattern, content, re.DOTALL | re.IGNORECASE):
    constraint_statements.append(match.group(0))

for constraint in constraint_statements:
    # Skip OWNER constraints
    if 'OWNER' not in constraint:
        sql_script.append(constraint)
        sql_script.append("")

# Extract indexes
print("Extracting indexes...")
index_pattern = r'CREATE (?:UNIQUE )?INDEX.*?ON public\.\w+.*?;'
indexes = re.findall(index_pattern, content, re.IGNORECASE | re.DOTALL)
for index in indexes:
    sql_script.append(index)
    sql_script.append("")

# Extract and convert data
print("Extracting and converting data...")
copy_pattern = r'COPY public\.(\w+) \((.*?)\) FROM stdin;(.*?)\\\.'
data_matches = list(re.finditer(copy_pattern, content, re.DOTALL))

for match in data_matches:
    table_name = match.group(1)
    columns = match.group(2)
    data_rows = match.group(3).strip()
    
    if data_rows:
        sql_script.append(f"-- Insert data into public.{table_name}")
        sql_script.append(f"INSERT INTO public.{table_name} ({columns}) VALUES")
        
        # Parse the data rows
        rows = []
        for line in data_rows.split('\n'):
            line = line.strip()
            if line and not line.startswith('--'):
                # Handle tab-separated values
                values = line.split('\t')
                # Escape single quotes and format values
                formatted_values = []
                for val in values:
                    if val == '\\N' or val == '':
                        formatted_values.append('NULL')
                    elif val.startswith('{') and val.endswith('}'):
                        # Array literal
                        formatted_values.append(f"'{val}'")
                    else:
                        # Escape single quotes
                        escaped_val = val.replace("'", "''")
                        formatted_values.append(f"'{escaped_val}'")
                
                rows.append(f"({', '.join(formatted_values)})")
        
        if rows:
            sql_script.append(',\n'.join(rows) + ';')
        sql_script.append("")

sql_script.append("COMMIT;")
sql_script.append("")

# Write to file
print(f"Writing SQL script to {output_file}...")
with open(output_file, 'w', encoding='utf-8') as f:
    f.write('\n'.join(sql_script))

print(f"✅ SQL script created successfully: {output_file}")
print(f"   Total lines: {len(sql_script)}")


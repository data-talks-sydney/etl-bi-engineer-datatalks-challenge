-- Integrate IAM user with Snowflake storage.
-- CREATE STORAGE INTEGRATION
create or replace storage integration S3_role_integration
    type = external_stage
    storage_provider = S3
    enabled = true
    storage_aws_role_arn = "arn:aws:iam::510139739254:role/snowflake_role"
    storage_allowed_locations = ("s3://data-talks-bi-engineer/");

-- Run storage integration description command
desc integration S3_role_integration;

-- Create Database
create or replace database biengineer;

-- Create schema RAW
create or replace schema S3_RAW;

--Select schema
use biengineer.s3_raw

-- Create Tables
create or replace table S3_users(files string);
create or replace table S3_products(files string);
create or replace table S3_interactions(files string);

-- Create Stage
use schema biengineer.s3_raw;
create or replace stage S3_users_stage
  url = ('s3://data-talks-bi-engineer/users/')
  storage_integration = S3_role_integration;

create or replace stage S3_products_stage
  url = ('s3://data-talks-bi-engineer/products/')
  storage_integration = S3_role_integration;

create or replace stage S3_interactions_stage
  url = ('s3://data-talks-bi-engineer/interactions/')
  storage_integration = S3_role_integration;

-- Create Pipes
create or replace pipe biengineer.s3_raw.S3_users_pipe auto_ingest=true as
  copy into biengineer.s3_raw.S3_users
  from @biengineer.s3_raw.S3_users_stage;

create or replace pipe biengineer.s3_raw.S3_products_pipe auto_ingest=true as
  copy into biengineer.s3_raw.S3_products
  from @biengineer.s3_raw.S3_products_stage;

create or replace pipe biengineer.s3_raw.S3_interactions_pipe auto_ingest=true as
  copy into biengineer.s3_raw.s3_interactions
  from @biengineer.s3_raw.S3_interactions_stage;

-- Create Role
use role securityadmin;
create or replace role S3_role;

-- Grant Object Access and Insert Permission
grant usage on database biengineer to role S3_role;
grant usage on schema biengineer.S3_RAW to role S3_role;
grant insert, select on biengineer.S3_RAW.s3_users to role S3_role;
grant insert, select on biengineer.S3_RAW.s3_products to role S3_role;
grant insert, select on biengineer.S3_RAW.s3_interactions to role S3_role;
grant usage on stage biengineer.S3_RAW.S3_users_stage to role S3_role;
grant usage on stage biengineer.S3_RAW.S3_products_stage to role S3_role;
grant usage on stage biengineer.S3_RAW.S3_interactions_stage to role S3_role;

-- Bestow S3_pipe Ownership
grant ownership on pipe biengineer.S3_RAW.S3_users_pipe to role S3_role;
grant ownership on pipe biengineer.S3_RAW.S3_products_pipe to role S3_role;
grant ownership on pipe biengineer.S3_RAW.S3_interactions_pipe to role S3_role;

-- Grant S3_role and Set as Default
grant role S3_role to user <username>;
alter user <username> set default_role = S3_role;
-- Import a CSV file in Snowflake with JSON values

-- Create a Database
create or replace database biengineer;

-- Select database
use biengineer;

-- Create schema RAW
create or replace schema RAW;

-- Select schema
use schema RAW;

-- Create a Snowflake stage (stage can be defined as an intermediary space for uploading/unloading source files)
create or replace stage users_stage;
create or replace stage interactions_stage;
create or replace stage products_stage;

-- Create a file format using the FILE FORMAT command to describe the format of the file to be imported
create or replace file format csv_format type = 'csv' field_delimiter = ',';

-- Upload CSV file from local folder using the PUT command
-- This step can not be performed by running the command from the Worksheets page on the Snowflake web interface.
-- You'll need to install and use SnowSQL client or DBeaver,for example, to do this
put file://C:\Users\edoni\OneDrive\Code\Challenge-BI-Engineer\data\users.csv @users_stage;
put file://C:\Users\edoni\OneDrive\Code\Challenge-BI-Engineer\data\interactions.csv @interactions_stage;
put file://C:\Users\edoni\OneDrive\Code\Challenge-BI-Engineer\data\products.csv @products_stage;

-- Check to see if the Snowflake stage is populated with the data from the file
select c.$1,
       c.$2,
       c.$3,
       c.$4,
       c.$5,
       to_json(c.$6),
       c.$7
from @users_stage c
where c.$1 <> 'id'

delete from @users_stage (file_format => USERS_FORMAT) c where c.$1 = 'id'

-- Create tables that has the same structure as the CSV file
create or replace table users(
    id integer,
    username varchar,
    email varchar,
    first_name varchar,
    last_name varchar,
    addresses varchar,
    age integer,
    gender varchar,
    persona	varchar,
    discount_persona string
);

create or replace table products(
    id string,
    url string,
    name string,
    category string,
    style string,
    description string,
    price float,
    image string,
    gender_affinity string,
    current_stock integer
);

create or replace table interactions(
    Item_ID string,
    User_ID integer,
    Event_Type string,
    Timestamp integer,
    Discount boolean
);

-- load data as it is organized in a CSV file
copy into users from @users_stage;
copy into interactions from @interactions_stage;
copy into products from @products_stage;

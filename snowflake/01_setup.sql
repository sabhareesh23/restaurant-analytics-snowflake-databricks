-- Snowflake S3 Integration Setup
CREATE OR REPLACE STORAGE INTEGRATION s3_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::220438081483:role/snowflake-s3-role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://sabhareesh23-restaurant-project-2026/');

CREATE OR REPLACE STAGE s3_stage
  URL = 's3://sabhareesh23-restaurant-project-2026/'
  STORAGE_INTEGRATION = s3_integration
  FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1 NULL_IF=('') EMPTY_FIELD_AS_NULL = TRUE);

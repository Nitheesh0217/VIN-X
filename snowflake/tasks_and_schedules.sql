CREATE OR REPLACE TASK vin.decode.daily_ingestion
WAREHOUSE = vin_wh
SCHEDULE = '1 DAY'
AS
COPY INTO vin.decode.lotstock
FROM @vin.decode.ext_stage
FILE_FORMAT = (FORMAT_NAME = vin.decode.csv_file_format)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

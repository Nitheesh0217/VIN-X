CREATE OR REPLACE STAGE vin.decode.ext_stage
  URL = 's3://your-bucket-name/Lotties_LotStock_Data.csv'
  FILE_FORMAT = vin.decode.csv_file_format;

-- Sample test case for validating VIN enrichment
SELECT vin, model_year, engine, make_name
FROM vin.decode.lotstock
WHERE model_year IS NOT NULL;

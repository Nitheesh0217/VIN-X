DECLARE cur CURSOR FOR
SELECT vin FROM vin.decode.lotstock;

FOR record IN cur DO
  LET enriched = (SELECT * FROM TABLE(PARSE_AND_ENHANCE_VIN(record.vin)));
  UPDATE vin.decode.lotstock
  SET manuf_name = enriched.manuf_name,
      make_name = enriched.make_name,
      model_year = enriched.model_year
  WHERE vin = record.vin;
END FOR;

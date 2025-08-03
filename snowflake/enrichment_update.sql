UPDATE vin.decode.lotstock t
SET manuf_name = s.manuf_name,
    vehicle_type = s.vehicle_type,
    make_name = s.make_name,
    plant_name = s.plant_name,
    model_year = s.model_year,
    desc1 = s.desc1,
    desc2 = s.desc2,
    engine = s.engine,
    drive_type = s.drive_type,
    transmission = s.transmission,
    mpg = s.mpg
FROM (
  SELECT ls.vin, pf.*
  FROM vin.decode.lotstock ls
  JOIN TABLE(PARSE_AND_ENHANCE_VIN(ls.vin)) pf ON pf.vin = ls.vin
) s
WHERE t.vin = s.vin;

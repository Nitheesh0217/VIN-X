

# VIN-X – Vehicle Identity Extraction Engine
![Snowflake](https://img.shields.io/badge/platform-Snowflake-blue)
![AWS S3](https://img.shields.io/badge/cloud-AWS%20S3-orange)
![Streamlit](https://img.shields.io/badge/frontend-Streamlit-red)
![Python](https://img.shields.io/badge/python-3.8%2B-blue)
---

## Overview

**VIN-X** is a cloud-native vehicle enrichment engine that transforms sparse Vehicle Identification Numbers (VINs) into fully decoded vehicle metadata. It leverages **Snowflake**, integrates with **AWS S3**, and optionally delivers a user-friendly **Streamlit** frontend. VIN-X demonstrates real-world data engineering and enrichment patterns using UDTFs, Secure Shares, and scalable ingestion.

### 🔍 Capabilities

- 🚘 Decode VINs into Make, Model, Year, Engine, Plant, Transmission, and more  
- ⛓️ Seamless integration with Snowflake Secure Shares and UDTFs  
- ☁️ Schema-tolerant ingestion via `COPY INTO` from AWS S3  
- 🧪 Table enrichment via set-based or row-wise updates  
- 📈 Optional Streamlit frontend for instant VIN decoding interface  

---

## 🔪 VIN Enrichment 

### 📅 Raw Input:
```csv
VIN,Exterior_Color,Interior_Color
SADCJ2FX2LA651904,White,Black
```

### ✅ Output:

| VIN               | MAKE   | MODEL_YEAR | PLANT_NAME  | ENGINE                            |
|-------------------|--------|------------|--------------|------------------------------------|
| SADCJ2FX2LA651904 | Jaguar | 2020       | Solihull, UK | Intercooled Turbo I-4 2.0 L / 122  |

---

## 🔄 Data Pipeline Overview

1. **Source**: VIN CSV uploaded to AWS S3  
2. **Stage Setup**: Snowflake `STAGE` defined with public or presigned URL  
3. **Ingestion**: `COPY INTO` using a defined `FILE FORMAT`  
4. **Enrichment**: Snowflake UDTF `PARSE_AND_ENHANCE_VIN()` from Secure Share  
5. **Table Update**: Enriched data merged into `LOTSTOCK` table  
6. **Interface**: Optional Streamlit UI for frontend queries  

---

## 📊 Architecture Diagram

```

<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/8171a69c-ea98-4f2d-b187-6f08c6d87e81" />

```

---

## 🧬 Core Snowflake SQL Logic

### 📁 File Format
```sql
CREATE FILE FORMAT vin.decode.csv_file_format
  TYPE = 'CSV'
  PARSE_HEADER = TRUE
  TRIM_SPACE = TRUE
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;
```

### 📁 Stage Definition
```sql
CREATE OR REPLACE STAGE vin.decode.ext_stage
  URL = 's3://your-bucket-name/Lotties_LotStock_Data.csv'
  FILE_FORMAT = vin.decode.csv_file_format;
```

### 📁 Data Ingestion
```sql
COPY INTO vin.decode.lotstock
FROM @vin.decode.ext_stage
FILE_FORMAT = (FORMAT_NAME = vin.decode.csv_file_format)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
```

### 🤕 VIN Enrichment (UDTF)
```sql
SELECT *
FROM TABLE(ADU_VIN.DECODE.PARSE_AND_ENHANCE_VIN('SADCJ2FX2LA651904'));
```

### 🔄 Table Enrichment (Set-Based Update)
```sql
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
```

---

## 🖥️ Streamlit Frontend 

```python
vin = st.text_input("Enter VIN:")
if vin:
    result = conn.cursor().execute(
        f"SELECT * FROM TABLE(ADU_VIN.DECODE.PARSE_AND_ENHANCE_VIN('{vin}'))"
    ).fetchall()
    st.write(result)
```

---

## 💡 Use Cases

- 📦 Dealership Inventory Audits  
- 🚨 Recall & Warranty Tracing  
- 📊 Sales Pattern Analytics  
- 📉 Resale Forecasting for Insurance  

---

## 📁 Folder Structure

```
vin-x/
├── streamlit_app/
│   ├── app.py
│   └── .streamlit/secrets.toml
├── snowflake/
│   ├── copy_into.sql
│   ├── enrichment_update.sql
│   ├── file_format.sql
│   └── create_stage.sql
├── data/
│   └── lotstock_sample.csv
├── assets/
│   └── architecture.png
├── README.md
└── LICENSE
```

---

## 🔒 Security & Governance

- 🔐 IAM or presigned-access based S3 staging  
- 🔨 Read-only Snowflake Secure Share (no internal logic exposed)  
- 🔑 Credentials securely stored in `.streamlit/secrets.toml`  

---

## 📜 License

This project is licensed under the MIT License – see [LICENSE](LICENSE).

---

> 🚀 Created by **Nitheesh Donepudi** | Snowflake ✕ AWS ✕ Streamlit | Real-World Data Engineering Project

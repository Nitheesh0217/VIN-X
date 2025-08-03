# 🧠 VIN-X System Architecture

VIN-X (Vehicle Identity Extraction Engine) is a cloud-native VIN decoding pipeline powered by Snowflake, AWS S3, and optional Streamlit. It ingests raw VIN data, enriches it using a shared Snowflake UDTF, and stores the results for analytics or frontend search.

This document outlines the architecture, data flow, and design principles behind the project.

---

## 🔧 1. Core Components Overview

| Component              | Type                  | Description                                                                 |
|------------------------|-----------------------|-----------------------------------------------------------------------------|
| `LOTSTOCK`             | Snowflake Table       | Holds raw and enriched VIN-level vehicle data                              |
| `AWS S3`               | Cloud Storage         | Stores VIN inventory CSV files for ingestion                               |
| `Snowflake Stage`      | External Stage        | Secure pointer to the CSV location in S3                                   |
| `File Format`          | CSV Parser            | Handles headered, inconsistent CSVs                                        |
| `PARSE_AND_ENHANCE_VIN`| UDTF (Shared Function)| Returns decoded vehicle metadata for each VIN                              |
| `Secure Share`         | Snowflake Share       | External metadata and logic provider (Auto Data Unlimited)                 |
| `Streamlit App`        | UI Layer              | Optional frontend for VIN decoding and search                              |

---

## 🧱 2. Component Breakdown

### 🏢 Snowflake Database
- **Purpose**: Core compute and storage engine.
- **Key Tables**:
  - `stock.unsold.lotstock`: Raw + enriched vehicle data.
  - `vin.decode.*`: Optional lookup and decoded data tables.
- **Features Used**:
  - `COPY INTO`, UDTF, `UPDATE`, SQL Scripting.

### ☁️ AWS S3 Bucket
- **Purpose**: Holds incoming VIN CSVs (`Lotties_LotStock_Data.csv`).
- **Access**: Via `STORAGE_INTEGRATION` or presigned URL.

### 🔐 Snowflake Secure Share
- **Provider**: `YNEVSIG.AUTO_DATA_UNLIMITED`
- **Shared Objects**:
  - UDTF: `PARSE_AND_ENHANCE_VIN()`
  - Tables: `MAKE_MODEL_VDS`, `MODEL_YEAR`, `MANUF_TO_MAKE`

### 🧾 Snowflake SQL Scripts
- `CREATE FILE FORMAT`, `CREATE STAGE`
- `COPY INTO` → `LOTSTOCK`
- `UPDATE` using join with UDTF

### 🖥️ Streamlit Frontend (Optional)
- **UI**: Text input, result table
- **Config**: `.streamlit/secrets.toml`

### ⚙️ Warehouses, Roles & Access
- **Warehouse**: `vin_wh` (XSMALL)
- **Roles**: `ACCOUNTADMIN`, `SYSADMIN`

---

## 🔄 3. Data Flow & Execution Pipeline

### Step 1: Ingestion from S3
```sql
COPY INTO vin.decode.lotstock
FROM @vin.decode.ext_stage
FILE_FORMAT = (FORMAT_NAME = vin.decode.csv_file_format)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
```

### Step 2: VIN Parsing via UDTF
```sql
SELECT *
FROM TABLE(ADU_VIN.DECODE.PARSE_AND_ENHANCE_VIN('<vin_value>'));
```

<p align="center">
  <img src="assets/ER Diagram.png" alt="VIN-X ER" width="100%">
</p>


### Step 3: Table Enrichment
```sql
UPDATE vin.decode.lotstock t
SET manuf_name = s.manuf_name, ...
FROM (
  SELECT ls.vin, pf.*
  FROM vin.decode.lotstock ls
  JOIN TABLE(PARSE_AND_ENHANCE_VIN(ls.vin)) pf ON pf.vin = ls.vin
) s
WHERE t.vin = s.vin;
```

### Step 4: Frontend Search (Optional)
- Built using Streamlit
- Real-time VIN lookup and decode

---

## 🧭 4. Database & Schema Design

### 📁 Databases
- `VIN`: Decoded vehicle metadata
- `STOCK`: Raw vehicle lot data
- `UTIL_DB`: File format & integration objects
- `ADU_VIN`: Shared database from provider

### 📁 Schemas
| Schema           | Purpose                            |
|------------------|-------------------------------------|
| `VIN.DECODE`     | Enriched decoded tables             |
| `STOCK.UNSOLD`   | Raw inventory VINs (`LOTSTOCK`)     |
| `UTIL_DB.PUBLIC` | Shared file format objects          |
| `ADU_VIN.DECODE` | UDTF and enrichment logic           |

### 📄 LOTSTOCK Table Structure
| Column         | Description                     |
|----------------|----------------------------------|
| vin            | VIN number                      |
| exterior       | Raw exterior color              |
| interior       | Raw interior color              |
| manuf_name     | Decoded manufacturer name       |
| model_year     | Decoded model year              |
| engine         | Decoded engine specs            |
| drive_type     | AWD/FWD/RWD                     |
| transmission   | Gear/Auto/Manual info           |
| mpg            | Mileage estimates               |

---

## 💡 5. Design Justifications

| Choice                          | Reason                                                                 |
|--------------------------------|------------------------------------------------------------------------|
| **Snowflake**                  | Scalable, serverless, easy UDTF usage                                  |
| **S3**                         | Cost-effective raw data storage                                        |
| **Modular Schemas**            | Easier separation of RAW vs CURATED data                               |
| **UDTF via Secure Share**      | No need to manage decode logic manually                                |
| **Streamlit frontend**         | User-friendly and demo-ready frontend                                  |
| **GitHub-friendly structure**  | Supports DevOps, CI/CD, and team onboarding                            |

---

## 🚀 6. Future Enhancements

- ✅ Scheduled ingestion using **Snowflake Tasks**
- ✅ VIN quality validation before enrichment
- ✅ Public REST API with Flask + Snowpark
- ✅ Power BI dashboard integration
- ✅ RBAC using Snowflake roles (`GRANT`-based)
- ✅ Multi-cloud ingestion support (Azure/GCP)
- ✅ Marketplace-ready Secure Share

---

> 📘 Author: **Nitheesh Donepudi** | VIN-X: Built with Snowflake ✕ S3 ✕ Streamlit


# 🚗 VIN-X – Vehicle Identity Extraction Engine

![Snowflake](https://img.shields.io/badge/platform-Snowflake-blue)
![AWS](https://img.shields.io/badge/cloud-AWS-orange)
![License](https://img.shields.io/badge/license-MIT-green)
![Frontend](https://img.shields.io/badge/frontend-Streamlit-black)

## 📌 Project Overview

**VIN-X** is a cloud-native vehicle enrichment pipeline that decodes sparse VIN data into a complete dataset for automotive analytics. Built on **Snowflake**, integrated with **AWS S3** and optionally exposed through a **Streamlit interface**, this project demonstrates real-world, production-grade data engineering practices for inventory enhancement.

### 🔍 Key Capabilities:
- 🚘 Decode VINs into Make, Model, Year, Plant, Engine, and more
- 🔗 Leverage Snowflake **Secure Share** & **UDTFs** for real-time enrichment
- ☁️ Resilient ingestion from AWS S3 using `COPY INTO`
- 🧠 Schema drift–tolerant data pipeline
- 💡 Optional Streamlit frontend for business-facing VIN lookup

---

## 🧪 VIN Enrichment – Before & After

### 📥 Raw Input:
```csv
VIN,Exterior_Color,Interior_Color
SADCJ2FX2LA651904,White,Black
```

### ✅ Enriched Output:
| VIN              | MAKE   | MODEL_YEAR | PLANT_NAME        | ENGINE                                 |
|------------------|--------|------------|--------------------|-----------------------------------------|
| SADCJ2FX2LA651904| Jaguar | 2020       | Solihull, UK       | Intercooled Turbo I-4 2.0 L / 122       |

---

## 🔄 Data Pipeline Overview

1. **Source**: Raw vehicle records (CSV) stored in AWS S3
2. **Staging**: External stage with IAM-secured Snowflake integration
3. **Ingestion**: `COPY INTO` with schema flexibility
4. **Transformation**: UDTF call – `PARSE_AND_ENHANCE_VIN(<VIN>)`
5. **Output**: Updated `LOTSTOCK` table with enriched vehicle data
6. **Interface**: Streamlit (optional) frontend for VIN lookup

---

## 📊 Architecture Diagram

📁 [View diagram in `/assets/architecture.png`](assets/architecture.png) *(placeholder)*

```
S3 (Raw VIN CSV) → Snowflake Stage → COPY INTO LOTSTOCK
     ↓                    ↓
Secure Share UDTF  →  Enriched Output
                           ↓
                     Streamlit UI (optional)
```

---

## 🧠 Core Snowflake Logic

### 📁 COPY INTO
```sql
COPY INTO STOCK.UNSOLD.LOTSTOCK
FROM @my_s3_stage/Lotties_LotStock_Data.csv
FILE_FORMAT = (FORMAT_NAME = 'my_csv_format')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
```

### 🧬 File Format
```sql
CREATE FILE FORMAT my_csv_format
TYPE = 'CSV'
ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
EMPTY_FIELD_AS_NULL = TRUE
TRIM_SPACE = TRUE;
```

### 🧪 UDTF Call
```sql
SELECT * FROM TABLE(ADU_VIN.DECODE.PARSE_AND_ENHANCE_VIN('SADCJ2FX2LA651904'));
```

---

## 🖥️ Streamlit Frontend (Optional)

![Streamlit Preview](assets/streamlit_demo.png)  
*Figure: Simple frontend allowing users to enrich a VIN*

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

- 📦 Dealership Inventory Management
- 🚨 Recall and Warranty Risk Flagging
- 📊 Sales Trend Forecasting
- 📉 Insurance & Resale Analytics

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
│   └── file_format.sql
├── data/
│   └── lotstock_sample.csv
├── assets/
│   └── architecture.png
├── README.md
└── LICENSE
```

---

## 🛡️ Security & Governance

- IAM-based S3 stage access via `STORAGE_INTEGRATION`
- Read-only access via Snowflake Secure Share
- All secrets stored in `.streamlit/secrets.toml` (excluded from repo)

---

## 📜 License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.

---

> Created by **Nitheesh Donepudi** as a real-world data engineering & analytics project.


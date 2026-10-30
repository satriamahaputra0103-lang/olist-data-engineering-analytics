# Olist E-Commerce Data Engineering & Analytics

An end-to-end data engineering and analytics project built using Python, PostgreSQL, dbt, Dagster, Apache Superset, and Docker.

The project transforms raw Brazilian e-commerce data into structured analytical datasets and interactive dashboards to support business analysis across sales performance, delivery performance, and customer experience.

## 1. Project Overview

This project uses the Olist Brazilian E-Commerce Public Dataset to demonstrate an end-to-end data pipeline, from raw CSV ingestion to business intelligence dashboards.

The pipeline consists of:

- **Extract and Load:** Python and Pandas ingest raw CSV files into PostgreSQL.
- **Transform:** dbt organizes source data into staging and analytical mart models.
- **Orchestration:** Dagster manages and executes the transformation pipeline.
- **Visualization:** Apache Superset presents analytical results through interactive dashboards.

## 2. Business Context

E-commerce businesses need reliable data to understand sales performance, delivery operations, and customer satisfaction.

Raw transactional data alone is not sufficient for business analysis. Data must be integrated, cleaned, transformed, and organized into analytical datasets.

This project addresses that need by developing an analytical data pipeline based on Olist's Brazilian e-commerce transactions.

## 3. Project Objectives

1. Build a repeatable ETL pipeline using Python.
2. Store transactional data in PostgreSQL.
3. Transform raw data into analytical models using dbt.
4. Implement data quality tests to validate analytical datasets.
5. Orchestrate data transformation using Dagster.
6. Develop interactive dashboards using Apache Superset.
7. Provide analytical datasets that support business decision-making.

## 4. Business Questions

The project focuses on four analytical areas.

### Sales Performance
- How does sales performance change over time?
- How many orders and items are processed?
- Which product categories contribute to sales?
- How does monthly sales performance develop?

### Delivery Performance
- How long does it take to deliver orders?
- How frequently are orders delivered later than estimated?
- How does delivery performance change over time?

### Customer Experience
- How do customers rate their purchasing experience?
- How are review scores distributed?
- What patterns can be observed between customer reviews and order information?

### Data Quality
- Are there missing values in important analytical fields?
- Are order relationships consistent across source tables?
- Are delivery sequences logically valid?

## 5. Dataset

**Source:** Olist Brazilian E-Commerce Public Dataset.

The dataset contains information about orders, customers, products, sellers, payments, reviews, and geolocation.

The original dataset includes multiple CSV files.

### Source Tables

| Dataset | Description |
|---|---|
| `olist_orders` | Order transactions and timestamps |
| `olist_customers` | Customer information |
| `olist_order_items` | Products included in orders |
| `olist_order_payments` | Payment information |
| `olist_order_reviews` | Customer reviews |
| `olist_products` | Product information |
| `olist_sellers` | Seller information |
| `olist_geolocation` | Geographical coordinates |
| `product_category_name_translation` | Product category translations |

The `olist_orders` dataset contains **99,441 records**.

The raw CSV files are not included in this repository. Users must obtain the dataset separately and place the files in `data_set_kagle/data/`.

## 6. Technology Stack

| Technology | Purpose |
|---|---|
| Python 3.13 | ETL development |
| Pandas | Data processing |
| SQLAlchemy | Database interaction |
| Psycopg | PostgreSQL connectivity |
| PostgreSQL 17 | Data storage |
| Docker | Container management |
| dbt Core | Data transformation |
| dbt-postgres | PostgreSQL adapter |
| Dagster | Data orchestration |
| Apache Superset 6.1.0 | Business intelligence |
| SQL | Data querying and validation |

## 7. Data Architecture

```text
             Olist CSV Dataset
                     |
                     v
              Python ETL
                     |
                     v
                PostgreSQL
                (public)
                     |
                     v
                 dbt Core
                     |
             +-------+-------+
             |               |
             v               v
          Staging           Marts
          (Views)          (Tables)
             |               |
             +-------+-------+
                     |
                     v
                  Dagster
              Orchestration
                     |
                     v
              Apache Superset
                     |
                     v
              Analytics Dashboard
```

Dagster orchestrates dbt transformations. Superset connects to PostgreSQL to visualize the resulting analytical tables.

## 8. Data Pipeline

### 8.1 Extract and Load

Python scripts are responsible for ingesting the source CSV files.

**Script 1: `etl_orders.py`**

- Reads `olist_orders_dataset.csv`.
- Converts five timestamp columns into datetime values.
- Calculates `delivery_duration_days`.
- Calculates `delivery_delay_days`.
- Loads the result into PostgreSQL as `public.olist_orders`.
- Uses `if_exists='fail'` to prevent overwriting an existing table.

**Script 2: `load_olist_tables.py`**

Loads eight additional source tables into PostgreSQL.

The script:
- Validates that all required CSV files exist.
- Checks that `public.olist_orders` already exists.
- Skips tables that already exist.
- Does not overwrite existing tables.
- Verifies that the row count of `olist_orders` remains unchanged.

### 8.2 Data Transformation with dbt

dbt transforms source tables into analytical models.

**Staging Layer**

Staging models standardize and prepare source data.

Models:
- `stg_orders`
- `stg_order_items`
- `stg_order_payments`
- `stg_order_reviews`

Materialization: Views.

Schema: `public_staging`.

**Mart Layer**

Mart models provide datasets for business analysis.

| Model | Purpose |
|---|---|
| `mart_monthly_sales` | Monthly sales analysis |
| `mart_delivery_performance` | Delivery performance analysis |
| `mart_customer_reviews` | Customer review analysis |
| `audit_data_quality` | Data quality monitoring |

Materialization: Tables.

Schema: `public_datamart`.

### 8.3 Data Quality and Testing

The project includes dbt tests to validate data integrity and analytical reliability.

Examples include:
- Schema-level data tests.
- Order relationship validation.
- Delivery sequence classification.
- Data quality audit checks.

The latest successful dbt build completed with:

- 8 models
- 15 data tests
- 23 successful execution results
- 0 errors
- 0 warnings
- 0 skipped results

### 8.4 Orchestration with Dagster

Dagster is used to orchestrate the dbt transformation workflow.

The project includes a Dagster definition in:

`olist_dbt/dagster_olist.py`

The Dagster development server can be started using:

`./run_dagster_olist.sh`

The web interface is normally available at:

`http://localhost:3000`

### 8.5 Business Intelligence with Apache Superset

Apache Superset provides interactive dashboards connected to PostgreSQL.

The unified dashboard contains three analytical sections:

1. Sales Performance
2. Customer Reviews
3. Delivery Performance

Superset runs in Docker and is accessible at:

`http://localhost:8088`

## 9. Project Results

The project successfully demonstrates:

- Loading 99,441 order records into PostgreSQL.
- Integrating eight additional Olist source tables.
- Building staging and mart models with dbt.
- Executing 8 dbt models and 15 data tests successfully.
- Orchestrating the transformation pipeline using Dagster.
- Creating an interactive analytics dashboard using Apache Superset.

The resulting analytical datasets support sales, delivery, customer review, and data quality analysis.

## 10. Project Structure

```text
bootcam_data_engineer/
│
├── belajar_de/
│   ├── docker-compose.yml
│   └── testSQL_docker.sql
│
├── data_set_kagle/
│   ├── data/                       # Raw CSV files (not tracked)
│   └── src/
│       ├── etl_orders.py
│       ├── load_olist_tables.py
│       ├── profiling.py
│       └── test_connection.py
│
├── docs/
│   └── DATA_ANALYTICS_REQUIREMENTS.md
│
├── olist_dbt/
│   ├── models/
│   │   ├── staging/
│   │   └── marts/
│   ├── tests/
│   ├── dagster_olist.py
│   └── dbt_project.yml
│
├── superset/
│   └── Dockerfile
│
├── docker-compose.superset.yml
├── requirements.txt
├── run_dagster_olist.sh
├── .env.example
├── .gitignore
└── README.md
```

## 11. Installation and Configuration

### Prerequisites

Install the following:

- Docker Desktop
- Python 3.13
- Git

### Step 1: Clone the Repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd bootcam_data_engineer
```

### Step 2: Configure Environment Variables

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` and configure the required variables.

Do not commit `.env` or share actual credentials.

### Step 3: Prepare the Olist Dataset

Download the Olist Brazilian E-Commerce Public Dataset.

Place the required CSV files in:

```text
data_set_kagle/data/
```

### Step 4: Start PostgreSQL

```bash
docker compose -f belajar_de/docker-compose.yml up -d
```

### Step 5: Create Python Environment

```bash
python3.13 -m venv .venv313
source .venv313/bin/activate
```

Install dependencies:

```bash
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

### Step 6: Configure dbt Profile

Create `olist_dbt/profiles.yml`:

```yaml
olist_dbt:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5432
      user: de_user
      password: "{{ env_var('POSTGRES_PASSWORD') }}"
      dbname: learning_db
      schema: public
      threads: 4
```

This file is intentionally excluded from Git because it contains database configuration.

### Step 7: Run the Python ETL

First, process the orders dataset:

```bash
python data_set_kagle/src/etl_orders.py
```

Then load the remaining source tables:

```bash
python data_set_kagle/src/load_olist_tables.py
```

The orders table must be created before loading the additional tables.

The ETL scripts use `if_exists='fail'` or skip existing tables. They are not intended to overwrite existing source data.

### Step 8: Run dbt

The following commands load environment variables from `.env` before executing dbt.

Check the database connection:

```bash
python -c "from dotenv import load_dotenv; load_dotenv('.env', override=True); import subprocess; raise SystemExit(subprocess.call(['dbt', 'debug'], cwd='olist_dbt'))"
```

Build the models and run tests:

```bash
python -c "from dotenv import load_dotenv; load_dotenv('.env', override=True); import subprocess; raise SystemExit(subprocess.call(['dbt', 'build'], cwd='olist_dbt'))"
```

### Step 9: Start Dagster

```bash
./run_dagster_olist.sh
```

Open the Dagster interface:

`http://localhost:3000`

### Step 10: Start Apache Superset

```bash
docker compose -f docker-compose.superset.yml up -d --build
```

Open Superset:

`http://localhost:8088`

Log in using the administrator credentials configured in `.env`.

Configure the PostgreSQL connection in Superset using the Docker network hostname:

```text
postgresql+psycopg2://de_user:<POSTGRES_PASSWORD>@de-postgres:5432/learning_db
```

Replace the placeholder with the actual PostgreSQL password. Do not publish this connection string with real credentials.

Register the analytical datasets from the `public_datamart` schema.

## 12. Limitations and Future Improvements

Potential future improvements include:

- Implementing incremental data loading.
- Adding automated data ingestion scheduling.
- Improving data quality monitoring.
- Integrating additional business dimensions.
- Adding more advanced sales and customer analytics.
- Implementing production-oriented logging and monitoring.
- Improving deployment and security configuration.

## 13. Documentation

For further details about business requirements and analytical scope, see:

`docs/DATA_ANALYTICS_REQUIREMENTS.md`

---

**Project:** Olist E-Commerce Data Engineering & Analytics
**Status:** Local end-to-end pipeline implemented and successfully tested.
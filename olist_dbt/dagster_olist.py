
"""Dagster pipeline untuk proyek Olist dbt."""

from pathlib import Path

from dotenv import load_dotenv
from dagster import (
    AssetExecutionContext,
    Definitions,
    ScheduleDefinition,
    define_asset_job,
)
from dagster_dbt import DbtCliResource, dbt_assets

ROOT = Path(__file__).resolve().parents[1]

# Memuat konfigurasi environment dari file .env
load_dotenv(ROOT / ".env")

DBT_PROJECT = ROOT / "olist_dbt"
DBT_PROFILES = DBT_PROJECT
DBT_MANIFEST = DBT_PROJECT / "target" / "manifest.json"
DBT_EXECUTABLE = ROOT / ".venv313" / "bin" / "dbt"


@dbt_assets(manifest=DBT_MANIFEST)
def olist_dbt_assets(
    context: AssetExecutionContext,
    dbt: DbtCliResource,
):
    """Menjalankan model dan pengujian dbt sebagai aset Dagster."""
    yield from dbt.cli(["build"], context=context).stream()


olist_job = define_asset_job(
    name="olist_dbt_pipeline",
    selection=[olist_dbt_assets],
)

olist_hourly_schedule = ScheduleDefinition(
    name="olist_hourly_pipeline_schedule",
    job=olist_job,
    cron_schedule="0 * * * *",
    execution_timezone="Asia/Makassar",
)

defs = Definitions(
    assets=[olist_dbt_assets],
    jobs=[olist_job],
    schedules=[olist_hourly_schedule],
    resources={
        "dbt": DbtCliResource(
            project_dir=DBT_PROJECT,
            profiles_dir=DBT_PROFILES,
            dbt_executable=str(DBT_EXECUTABLE),
        ),
    },
)

#!/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$ROOT/.dagster_home"

export DAGSTER_HOME="$ROOT/.dagster_home"

cd "$ROOT"

exec "$ROOT/.venv313/bin/dagster" dev \
  -f "$ROOT/olist_dbt/dagster_olist.py"

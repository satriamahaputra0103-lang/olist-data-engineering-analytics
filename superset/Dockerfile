FROM apache/superset:6.1.0

USER root

RUN uv pip install --python /app/.venv/bin/python psycopg2-binary==2.9.13

USER superset

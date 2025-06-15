from sqlmesh.core.config import (
    Config,
    GatewayConfig,
    ModelDefaultsConfig,
    NameInferenceConfig
)
from sqlmesh.core.config.connection import (
    PostgresConnectionConfig,
    ClickhouseConnectionConfig,
    DuckDBConnectionConfig,
    DuckDBAttachOptions
)
from dotenv import load_dotenv
from os import environ

load_dotenv()

state_connection = PostgresConnectionConfig(
    host=environ.get("POSTGRES_HOST"),
    user=environ.get("POSTGRES_USER"),
    password=environ.get("POSTGRES_PASSWORD"),
    database=environ.get("POSTGRES_DATABASE"),
    port=int(environ.get("POSTGRES_PORT") or 0),
)

ch_connection = ClickhouseConnectionConfig(
    concurrent_tasks=4,
    host=environ.get("CLICKHOUSE_HOST"),
    username=environ.get("CLICKHOUSE_USER"),
    password=environ.get("CLICKHOUSE_PASSWORD"),
    port=int(environ.get("CLICKHOUSE_PORT") or 0),
)

duckdb_connection = DuckDBConnectionConfig(
    extensions=[
        {'name': 'httpfs'},
        {'name': 'ducklake'},
        {'name': 'postgres'}
    ],
    secrets=[
        {
            'type': 's3',
            'endpoint': '192.168.0.71:30878',
            'key_id': environ.get("S3_USER"),
            'secret': environ.get("S3_PASSWORD"),
            'url_style': 'path',
            'use_ssl': False
        }
    ],
    catalogs={
        'ducklake': DuckDBAttachOptions(
            type="ducklake",
            path=f"postgres:dbname=ducklake host=192.168.0.71 port=5432 password={environ.get('DUCKDB_POSTGRES_PASSWORD')} user={environ.get('DUCKDB_POSTGRES_USER')}",
            data_path="s3://ducklake",
        )
    }
)

config = Config(
    gateways={
        "clickhouse": GatewayConfig(
            connection=ch_connection,
            state_connection=state_connection,
            test_connection=ch_connection,
        ),
        "duckdb": GatewayConfig(
            connection=duckdb_connection,
            state_connection=state_connection,
            test_connection=duckdb_connection
        )
    },
    default_gateway="duckdb",
    disable_anonymized_analytics=True,
    model_defaults=ModelDefaultsConfig(dialect="duckdb", start=None),
    model_naming=NameInferenceConfig(infer_names=True),
    gateway_managed_virtual_layer=True
)

from sqlmesh.core.config import (
    Config,
    GatewayConfig,
    ModelDefaultsConfig,
    NameInferenceConfig
)
from sqlmesh.core.config.connection import (
    PostgresConnectionConfig,
    ClickhouseConnectionConfig,
)
from dotenv import load_dotenv
from os import environ

load_dotenv()

ch_connection = ClickhouseConnectionConfig(
    concurrent_tasks=4,
    host=environ.get("CLICKHOUSE_HOST"),
    username=environ.get("CLICKHOUSE_USER"),
    password=environ.get("CLICKHOUSE_PASSWORD"),
    port=int(environ.get("CLICKHOUSE_PORT")),
)

config = Config(
    gateways={
        "default": GatewayConfig(
            connection=ch_connection,
            state_connection=PostgresConnectionConfig(
                host=environ.get("POSTGRES_HOST"),
                user=environ.get("POSTGRES_USER"),
                password=environ.get("POSTGRES_PASSWORD"),
                database=environ.get("POSTGRES_DATABASE"),
                port=int(environ.get("POSTGRES_PORT")),
            ),
            test_connection=ch_connection,
        )
    },
    default_gateway="default",
    disable_anonymized_analytics=True,
    model_defaults=ModelDefaultsConfig(dialect="clickhouse", start=None),
    model_naming=NameInferenceConfig(infer_names=True),
)

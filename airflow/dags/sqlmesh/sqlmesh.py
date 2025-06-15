from airflow.sdk import dag, task
# from utils.logging import print_data

def send_err_log(context):
    from airflow.hooks.base import BaseHook
    import httpx
    import json

    logs_conn = BaseHook.get_connection("airflow_logs")
    tg_conn = BaseHook.get_connection("tg_alerts")
    host=logs_conn.host
    port=logs_conn.port

    token = httpx.post(
        f'{host}:{port}/auth/token',
        data=json.dumps({
            'username': logs_conn.login,
            'password': logs_conn.password
        }),
        headers={
            'Content-Type': 'application/json'
        },
    ).json()['access_token']

    task_instance = context.get('ti')
    dag_id = task_instance.dag_id
    run_id = task_instance.run_id
    task_id = task_instance.task_id
    try_number = task_instance.try_number
    
    data = httpx.get(
        f'{host}:{port}/api/v2/dags/{dag_id}/dagRuns/{run_id}/taskInstances/{task_id}/logs/{try_number}',
        headers={
            'Authorization': f'Bearer {token}'
        },
        params={'full_content':'false'}
    ).json()['content']

    msg = ''

    for line in data:
        if line.get('error_detail'):
            for i in line.get('error_detail'):
                msg += i.get('exc_type') + '\n\t' + i.get('exc_value')
                msg += '\n'

    full_msg = f"""
    Dag run failed!
    Dag name: {dag_id}
    Run id: {run_id}
    Task id: {task_id}
    Error: <blockquote>{msg}</blockquote>
    """

    data = httpx.get(
        url=tg_conn.host+tg_conn.password+'/sendMessage',
        params={
            'chat_id': tg_conn.login,
            'text': full_msg,
            'parse_mode': 'HTML'
        }
    )

    print(data)

@dag(schedule='*/30 * * * *', max_active_runs=1)
def run_sqlmesh_models():

    @task(on_failure_callback=send_err_log)
    def run():
        from airflow.hooks.base import BaseHook
        
        from sqlmesh.core.context import Context
        from sqlmesh.core.config import Config, GatewayConfig
        from sqlmesh.core.config.connection import (
            PostgresConnectionConfig,
            ClickhouseConnectionConfig,
            DuckDBConnectionConfig,
            DuckDBAttachOptions
        )        

        clickhouse_conn = BaseHook.get_connection("sqlmesh_clickhouse")
        state_conn = BaseHook.get_connection("sqlmesh_state")
        ducklake_state_conn = BaseHook.get_connection("sqlmesh_ducklake_state")
        ducklake_data_conn = BaseHook.get_connection("sqlmesh_ducklake_data")

        ch_connection = ClickhouseConnectionConfig(
            concurrent_tasks=8,
            pretty_sql=False,
            host=clickhouse_conn.host,
            username=clickhouse_conn.login,
            password=clickhouse_conn.password,
            port=int(clickhouse_conn.port or 8123)
        )

        state_connection = PostgresConnectionConfig(
            host=state_conn.host,
            user=state_conn.login,
            password=state_conn.password,
            database=state_conn.schema,
            port=int(state_conn.port or 5432),
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
                    'endpoint': (ducklake_data_conn.host+':'+str(ducklake_data_conn.port)),
                    'key_id': ducklake_data_conn.login,
                    'secret': ducklake_data_conn.password,
                    'url_style': 'path',
                    'use_ssl': False
                }
            ],
            catalogs={
                'ducklake': DuckDBAttachOptions(
                    type="ducklake",
                    path=f"postgres:dbname=ducklake host={ducklake_state_conn.host} port={(ducklake_state_conn.port or 5432)} password={ducklake_state_conn.password} user={ducklake_state_conn.login}",
                    data_path="s3://ducklake",
                )
            }
        )

        ctx = Context(
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
                gateway_managed_virtual_layer=True
            )
        )
        
        result = ctx.run()

        print('Result: {}'.format(result.name))

        if result.is_failure:
            raise ValueError("SQLMesh run error!")

    run()


run_sqlmesh_models()

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
        )

        import sys
        from pprint import pprint

        pprint(sys.path)

        conn_run = BaseHook.get_connection("sqlmesh_data")
        conn_state = BaseHook.get_connection("sqlmesh_state")

        ch_connection = ClickhouseConnectionConfig(
            concurrent_tasks=8,
            pretty_sql=False,
            host=conn_run.host,
            username=conn_run.login,
            password=conn_run.password,
            port=conn_run.port
        )

        ctx = Context(
            config=Config(
                gateways={
                    "default": GatewayConfig(
                        connection=ch_connection,
                        state_connection=PostgresConnectionConfig(
                            host=conn_state.host,
                            user=conn_state.login,
                            password=conn_state.password,
                            database=conn_state.schema,
                            port=conn_state.port,
                        ),
                        test_connection=ch_connection
                    )
                },
                disable_anonymized_analytics=True,
            )
        )
        
        result = ctx.run()

        print('Result: {}'.format(result.name))

        if result.is_failure:
            raise ValueError("SQLMesh run error!")

    run()


run_sqlmesh_models()

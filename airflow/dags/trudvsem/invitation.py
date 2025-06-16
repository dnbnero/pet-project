from airflow.sdk import dag, task
from datetime import datetime, timedelta

@dag(
    schedule='@daily',
    start_date=datetime(2020,1,1),
    catchup=True,
    default_args={
        'pool': 'trudvsem',
        'retries': 3,
        'retry_delay': timedelta(minutes=5)
    }
)
def invitation():

    @task(show_return_value_in_logs=False)
    def get_history(date):
        from trudvsem._utils import get_history

        return get_history(
            'https://opendata.trudvsem.ru/7710538364-invitation/',
            date
        )
    
    @task
    def get_data(link: dict):
        print(link)

    links = get_history(
        date='{{ data_interval_start | ds }}'
    )

    get_data.expand(link=links)



invitation()
from airflow.sdk import dag, task

@dag 
def invitation():

    @task
    def get_history(date):
        from trudvsem._utils import get_history

        return get_history(
            'https://opendata.trudvsem.ru/7710538364-invitation/',
            date
        )
    
    get_history(
        date='{{ data_interval_start | ds }}'
    )

invitation()
"""
colocar aqui funcionalidade da dag detalhada
"""
import os 

os.environ['AWS_DEFAULT_REGION'] = 'us-east-1'


from datetime import datetime
from airflow.decorators import dag, task
from airflow.operators.empty import EmptyOperator

from airflow.providers.amazon.aws.operators.dms import DmsStartTaskOperator


MY_REPLICATION_TASK_ARN = "arn:aws:dms:us-east-1:628381083261:task:LWZZ6O4JHAJN5X64EJIYLRQ55NRZQMUZMSKQPEQ"


# argumentos padrões da minha dag
default_args = {
    "owner": "Jv",
    "retries": 0,
    "retry_delay": 0
}

@dag(
    dag_id="start_dms_migration",
    start_date=datetime(2023,12,6),
    schedule_interval=None,
    max_active_runs=1,
    catchup=False,
    default_args=default_args,
    tags=["dms", "migration", "s3", "mysql", "dev", "etl"]
)
def start_dms_migration():

    init = EmptyOperator(task_id="init")

    start_dms = DmsStartTaskOperator(
        task_id = "start_dms_migration",
        replication_task_arn=MY_REPLICATION_TASK_ARN,
        start_replication_task_type="resume-processing",
        aws_conn_id="aws_default"
)

    finish = EmptyOperator(task_id="finish")

    init >> start_dms >> finish

dag = start_dms_migration()
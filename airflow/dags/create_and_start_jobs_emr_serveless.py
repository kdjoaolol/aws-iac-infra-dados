"""
colocar aqui funcionalidade da dag detalhada
"""
from datetime import datetime, timedelta
from airflow.decorators import dag, task
from airflow.operators.empty import EmptyOperator


AWS_CONN_ID = "creds-via-terraform-env"

# argumentos padrões da minha dag
default_args = {
    "owner": "Jv",
    "retries": 1,
    "retry_delay": 0
}

@dag(
    dag_id="create_and_start_jobs_emr_serveless",
    start_date=datetime(2023,12,6),
    schedule_interval=timedelta(hours=1),
    max_active_runs=1,
    catchup=False,
    default_args=default_args,
    tags=["emr", "serveless", "spark", "dev", "etl"]
)
def create_and_start_jobs_emr_serveless():

    init = EmptyOperator(task_id="init")

    # desenvolver criação e ativação de job no emr serveless

    finish = EmptyOperator(task_id="finish")

    init >> finish

dag = create_and_start_jobs_emr_serveless()

# TODO criação de script spark para lançar no s3 e chamrmos o app.py pelos parametros do submit na hora de realizar a task 
# TODO script estando pronto, precisamos criar um terraform para subir o airflow no aws via mwaa
# TODO airflow estando ok, vamos subir o airflow local para o na nuvem e executar job serveless orquestrado
# TODO jobs ok, vamos criar uma dag que envia o dado da camada gold para o redshift via airflow
"""
colocar aqui funcionalidade da dag detalhada
"""
import os 

os.environ['AWS_DEFAULT_REGION'] = 'us-east-1'


from datetime import datetime, timedelta
from airflow.decorators import dag, task
from airflow.operators.empty import EmptyOperator

from airflow.providers.amazon.aws.operators.emr import (
    EmrServerlessStartJobOperator
)


APPLICATION_EMR = "00fghejavp31b909"
JOB_ID = "start_emr_serverless_job"


# argumentos padrões da minha dag
default_args = {
    "owner": "Jv",
    "retries": 0,
    "retry_delay": 0
}

@dag(
    dag_id="create_and_start_jobs_emr_serveless",
    start_date=datetime(2023,12,6),
    schedule_interval=None,
    max_active_runs=1,
    catchup=False,
    default_args=default_args,
    tags=["emr", "serveless", "spark", "dev", "etl"]
)
def create_and_start_jobs_emr_serveless():

    init = EmptyOperator(task_id="init")

    start_job = EmrServerlessStartJobOperator(
    task_id=JOB_ID,
    application_id=APPLICATION_EMR, # TODO COLOCAR DE FORMA DINAMICA QUANDO SUBIR PARA O AIRFLOW PARA O AWS
    execution_role_arn='arn:aws:iam::628381083261:role/iac_Role_Emr_Serverless_s3_glue',
    job_driver = { 
                    "sparkSubmit": {
                        "entryPoint": "s3://iac-scripts-jvam-iac/jobs/Processador.py",
                        "sparkSubmitParameters": '--conf spark.executor.cores=2 \
                            --conf spark.executor.memory=4g \
                            --conf spark.driver.cores=1 \
                            --conf spark.driver.memory=4g \
                            --conf spark.executor.instances=2 \
                            --packages io.delta:delta-core_2.12:2.0.2 \
                            --jars s3://iac-scripts-jvam-iac/jars/delta-core_2.12-2.0.2.jar'
                    }
                },
    configuration_overrides = {  
        "monitoringConfiguration": {
            "managedPersistenceMonitoringConfiguration": {
            "enabled": True
            },
            "cloudWatchLoggingConfiguration": {
            "enabled": True
            },
            "s3MonitoringConfiguration": {
                "logUri": f"s3://iac-scripts-jvam-iac/"
            }
        },
    },
    config={"name": "landing-to-bronze-delta"}
)

    finish = EmptyOperator(task_id="finish")

    init >> start_job >> finish

dag = create_and_start_jobs_emr_serveless()

# TODO criação de script spark para lançar no s3 e chamrmos o app.py pelos parametros do submit na hora de realizar a task 
# TODO script estando pronto, precisamos criar um terraform para subir o airflow no aws via mwaa
# TODO airflow estando ok, vamos subir o airflow local para o na nuvem e executar job serveless orquestrado
# TODO jobs ok, vamos criar uma dag que envia o dado da camada gold para o redshift via airflow
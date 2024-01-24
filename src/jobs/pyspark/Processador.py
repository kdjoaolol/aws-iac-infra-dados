from pyspark.sql import SparkSession
# from delta.tables import *


class Processador():
    def __init__(
            self,
            landing_bucket: str = None,
            bronze_bucket: str = None,
            silver_bucket: str = None,
            gold_bucket: str = None,
            spark = SparkSession.builder.getOrCreate()       
            ):
        
        self.spark = spark
        self.landing_bucket = landing_bucket
        self.bronze_bucket = bronze_bucket
        self.silver_bucket = silver_bucket
        self.gold_bucket = gold_bucket

    def landing_para_bronze(self, tables: list, input_format: str):

        self.spark.sparkContext.setLogLevel("INFO")

        for table in tables: 
            dataset = self.spark.read.format(input_format).load(f"s3a://{self.landing_bucket}/mysql-main-app/databasemysqliac/{table}")
            dataset.write.mode('overwrite').format("delta").save(f"s3a://{self.bronze_bucket}/{table}")

            # deltaTable = DeltaTable.forPath(self.spark, f"s3a://{self.bronze_bucket}/{table}")
            # deltaTable.generate("symlink_format_manifest")

if __name__ == "__main__":
    delta = Processador(landing_bucket = "iac-landing-jvam-iac", 
                        bronze_bucket = "iac-bronze-jvam-iac",
                        silver_bucket = "iac-silver-jvam-iac",
                        gold_bucket= "iac-gold-jvam-iac")
    
    delta.landing_para_bronze(tables = ["customers", "credit_score", "flight", "vehicle"], input_format = "parquet")
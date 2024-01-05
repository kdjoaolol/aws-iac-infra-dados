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

    def landing_para_bronze(self, table: str, input_format: str):

        self.spark.setLogLevel("INFO")

        dataset = self.spark.read.format(input_format).load(f"s3a://{self.landing_bucket}/mysql-main-app/databasemysqliac/{table}")
        dataset.write.mode('overwrite').format("parquet").save(f"s3a://{self.bronze_bucket}/{table}")

        # deltaTable = DeltaTable.forPath(self.spark, f"s3a://{self.bronze_bucket}/{table}")
        # deltaTable.generate("symlink_format_manifest")

if __name__ == "__main__":
    delta = Processador(landing_zone_bucket = "landing-jvam-iac", 
                            bronze_bucket = "bronze-jvam-iac",
                            silver_bucket = "silver-jvam-iac",
                            gold_bucket= "gold-jvam-iac")
    
    delta.landing_para_bronze(
                                table = "credit_score",
                                input_format = "parquet")
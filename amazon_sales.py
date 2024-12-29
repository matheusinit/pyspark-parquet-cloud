# import os
# from datetime import datetime
import argparse

# from dotenv import load_dotenv
from pyspark.sql import SparkSession
# import boto3


def write_raw_data_in_bronze_layer(data_source_uri: str, data_output_uri: str) -> None:
    # hadoop_jar = "org.apache.hadoop:hadoop-aws:3.3.4"
    # aws_jar = "com.amazonaws:aws-java-sdk-bundle:1.12.518"

    # jars = f"{hadoop_jar},{aws_jar}"
    # .config("spark.jars.packages", jars) \

    spark = SparkSession \
        .builder \
        .appName("Amazon Sales Data") \
        .getOrCreate()

    amazon_sale_report = spark.read.csv(
        data_source_uri,
        header=True
    )

    amazon_sale_report = amazon_sale_report.drop('Unnamed: 22', 'index')

    # load_dotenv()

    # aws_access_key_id = os.getenv('AWS_ACCESS_KEY_ID')
    # aws_secret_access_key = os.getenv('AWS_SECRET_ACCESS_KEY')
    # aws_default_region = os.getenv('AWS_DEFAULT_REGION')
    # aws_role_arn = os.getenv('AWS_ROLE_ARN')

    # client = boto3.client('sts', aws_access_key_id=aws_access_key_id,
    #                       aws_secret_access_key=aws_secret_access_key)

    # assumed_role_object = client.assume_role(
    #     RoleArn=aws_role_arn,
    #     RoleSessionName="WriteParquetSession"
    # )

    # credentials = assumed_role_object['Credentials']

    # temp_access_key_id = credentials['AccessKeyId']
    # temp_secret_access_key = credentials['SecretAccessKey']
    # temp_session_token = credentials['SessionToken']

    # hadoop_conf = spark.sparkContext._jsc.hadoopConfiguration()
    # hadoop_conf.set('fs.s3a.access.key', temp_access_key_id)
    # hadoop_conf.set('fs.s3a.secret.key', temp_secret_access_key)
    # hadoop_conf.set('fs.s3a.session.token', temp_session_token)
    # hadoop_conf.set('fs.s3a.endpoint',
    #                 f's3.{aws_default_region}.amazonaws.com')

    # s3_bucket = "s3a://amazon-sales"

    # current_datetime = datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
    # s3_path = f"{s3_bucket}/bronze/pos/sales_transactions/{current_datetime}/data.parquet"

    amazon_sale_report.write.parquet(data_output_uri)

    spark.stop()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--data_source_uri')
    parser.add_argument('--data_output_uri')
    args = parser.parse_args()
    write_raw_data_in_bronze_layer(args.data_source_uri, args.data_output_uri)

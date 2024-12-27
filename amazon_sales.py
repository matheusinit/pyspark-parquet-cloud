import os
from datetime import datetime

from dotenv import load_dotenv
import kagglehub
from pyspark.sql import SparkSession
import boto3


def download_dataset_from_kaggle(dataset: str, path: str) -> None:
    """
    Downloads a dataset from Kaggle.

    Args:
        dataset (str): The handle of the Kaggle dataset to download.
        path (str): The local directory path where the dataset should be downloaded.

    Raises:
        Exception: If any error occurs during the download process.

    Returns:
        None
    """
    try:
        kagglehub.dataset_download(
            handle=dataset,
            path=path
        )

        print(f"Dataset {dataset} downloaded successfully.")
    except Exception as e:
        print(f"Error downloading dataset: {e}")


def upload_file_to_s3(file_path: str, bucket_name: str, object_key: str) -> None:
    """
    Uploads a file to an S3 bucket.

    Args:
        file_path (str): The path to the local file.
        bucket_name (str): The name of the S3 bucket.
        object_key (str): The desired key (object name) for the file in the S3 bucket.

    Returns:
        None
    """

    try:
        s3 = boto3.client('s3')
        s3.upload_file(file_path, bucket_name, object_key)
        print(f"File '{file_path}' uploaded to s3://{bucket_name}/{object_key}")
    except Exception as e:
        print(f"Error uploading file: {e}")


def write_raw_data_in_bronze_layer() -> None:
    hadoop_jar = "org.apache.hadoop:hadoop-aws:3.3.4"
    aws_jar = "com.amazonaws:aws-java-sdk-bundle:1.12.518"

    jars = f"{hadoop_jar},{aws_jar}"

    spark = SparkSession \
        .builder \
        .appName("Amazon Sales Data") \
        .config("spark.jars.packages", jars) \
        .getOrCreate()

    amazon_sale_report = spark.read.csv(
        f"{path}/Amazon Sale Report.csv",
        header=True
    )

    amazon_sale_report = amazon_sale_report.drop('Unnamed: 22', 'index')

    load_dotenv()

    aws_access_key_id = os.getenv('AWS_ACCESS_KEY_ID')
    aws_secret_access_key = os.getenv('AWS_SECRET_ACCESS_KEY')
    aws_default_region = os.getenv('AWS_DEFAULT_REGION')
    aws_role_arn = os.getenv('AWS_ROLE_ARN')

    client = boto3.client('sts', aws_access_key_id=aws_access_key_id,
                          aws_secret_access_key=aws_secret_access_key)

    assumed_role_object = client.assume_role(
        RoleArn=aws_role_arn,
        RoleSessionName="WriteParquetSession"
    )

    credentials = assumed_role_object['Credentials']

    temp_access_key_id = credentials['AccessKeyId']
    temp_secret_access_key = credentials['SecretAccessKey']
    temp_session_token = credentials['SessionToken']

    hadoop_conf = spark.sparkContext._jsc.hadoopConfiguration()
    hadoop_conf.set('fs.s3a.access.key', temp_access_key_id)
    hadoop_conf.set('fs.s3a.secret.key', temp_secret_access_key)
    hadoop_conf.set('fs.s3a.session.token', temp_session_token)
    hadoop_conf.set('fs.s3a.endpoint',
                    f's3.{aws_default_region}.amazonaws.com')

    s3_bucket = "s3a://amazon-sales"

    current_datetime = datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
    s3_path = f"{s3_bucket}/bronze/pos/sales_transactions/{current_datetime}/data.parquet"

    amazon_sale_report.write.parquet(s3_path)

    spark.stop()


if __name__ == "__main__":
    dataset = "thedevastator/unlock-profits-with-e-commerce-sales-data"
    download_dataset_from_kaggle(dataset, path="data/")
    upload_file_to_s3(
        "data/Amazon Sale Report.csv",
        bucket_name="amazon-sales",
        object_key="dataset/amazon-sale-report.csv"
    )
    write_raw_data_in_bronze_layer()

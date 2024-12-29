import argparse
import os
import shutil

import kagglehub
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
        dataset_path = kagglehub.dataset_download(
            handle=dataset
        )

        os.makedirs(path, exist_ok=True)

        for file_name in os.listdir(dataset_path):
            full_file_name = os.path.join(dataset_path, file_name)
            if os.path.isfile(full_file_name):
                shutil.copy(full_file_name, path)

        print(f"Dataset {dataset} downloaded successfully.")
    except Exception as e:
        print(f"Error downloading dataset: {e}")
        raise e


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


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--object_key', type=str,
                        default="./amazon-sale-report.csv")
    parser.add_argument('--bucket_name', type=str, default="amazon-sales")
    parser.add_argument('--dataset_download_path', type=str, default="./data")
    args = parser.parse_args()
    DATASET = "thedevastator/unlock-profits-with-e-commerce-sales-data"
    download_dataset_from_kaggle(DATASET, args.dataset_download_path)
    upload_file_to_s3(
        os.path.join(args.dataset_download_path, "Amazon Sale Report.csv"),
        bucket_name=args.bucket_name,
        object_key=args.object_key
    )

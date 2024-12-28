# PySpark Parquet Project

![Project Banner](.github/banner.webp)

## Goal

The goal of this project is to demonstrate how to use PySpark to read, write, and process Parquet files in a distributed environment using AWS cloud services. This project follows the Medallion Architecture, utilizing CSV files as raw data and storing processed data in Parquet format on Amazon S3 across different layers (Bronze, Silver, and Gold). The project provides examples and best practices for handling Parquet files efficiently in a cloud-based setup.

## Source Dataset

This project uses the [Unlock Profits with E-Commerce Sales Data](https://www.kaggle.com/datasets/thedevastator/unlock-profits-with-e-commerce-sales-data) dataset from Kaggle as the source dataset. The main CSV file used for input is `Amazon Sale Report.csv`.

## Tools Used
- **Poetry**: A dependency management and packaging tool for Python.
- **PySpark**: A Python API for Spark, used for distributed data processing.
- **Parquet**: A columnar storage file format optimized for use with big data processing frameworks.
- **Jupyter Notebook**: For creating and sharing documents that contain live code, equations, visualizations, and narrative text.
- **AWS**: Amazon Web Services, a comprehensive cloud computing platform provided by Amazon.
- **Terraform**: An infrastructure as code tool for building, changing, and versioning infrastructure safely and efficiently.

## Project Structure
```
pyspark-parquet-cloud/
│
├── data/
│   ├── *.csv
├── iac/
│   ├── .terraform.lock.hcl
│   ├── emr.tf
│   ├── iam.tf
│   ├── main.tf
│   ├── s3.tf
│   ├── security_group.tf
│   ├── set_env_vars.sh
│   └── vpc.tf
│
├── .gitignore
├── amazon_sales.py
├── eda.ipynb
├── poetry.lock
├── pyproject.toml
└── README.md
```

### Folders and Files

#### data/
- **\*.csv**: Contains sample CSV data files used for demonstration and testing purposes.

#### iac/
- **.terraform.lock.hcl**: Lock file for Terraform to ensure consistent infrastructure deployments.
- **emr.tf**: Terraform configuration for setting up an EMR cluster.
- **iam.tf**: Terraform configuration for managing IAM roles and policies.
- **main.tf**: Main Terraform configuration file.
- **s3.tf**: Terraform configuration for setting up S3 buckets.
- **security_group.tf**: Terraform configuration for managing security groups.
- **set_env_vars.sh**: Shell script for setting environment variables.
- **vpc.tf**: Terraform configuration for setting up a VPC.

#### .gitignore
- Specifies files and directories to be ignored by Git.

#### amazon_sales.py
- Python script for processing Amazon sales data.

#### eda.ipynb
- Jupyter Notebook for exploratory data analysis.

#### poetry.lock
- Lock file for Poetry to ensure consistent dependency installations.

#### pyproject.toml
- Configuration file for Poetry, specifying project dependencies and settings.

#### README.md
- Provides an overview of the project, setup instructions, and usage guidelines.

## Setup

1. **Clone the repository:**
  ```sh
  git clone https://github.com/matheusinit/pyspark-parquet-cloud.git
  cd pyspark-parquet-cloud
  ```

2. **Install Poetry:**
  ```sh
  curl -sSL https://install.python-poetry.org | python3 -
  ```

3. **Install the required dependencies:**
  ```sh
  poetry install
  ```

4. **Activate the virtual environment:**
  ```sh
  poetry shell
  ```

## Usage

To run this project with the cloud setup in mind, you need to set up and apply Terraform configurations on AWS and configure your AWS credentials.

### Installing AWS CLI on Linux

To install the AWS CLI on a Linux system, follow these steps:

1. **Download the AWS CLI installer:**
  ```sh
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  ```

2. **Unzip the installer:**
  ```sh
  unzip awscliv2.zip
  ```

3. **Run the installer:**
  ```sh
  sudo ./aws/install
  ```

4. **Verify the installation:**
  ```sh
  aws --version
  ```

### Infrastructure Setup

This should output the version of the AWS CLI installed, confirming that the installation was successful.
1. **Set up AWS credentials:**
  Ensure you have your AWS credentials configured. You can set them up in a `.env` file or use the AWS CLI to configure them:
  ```sh
  aws configure
  ```

2. **Initialize Terraform:**
  Navigate to the `iac/` directory and initialize Terraform:
  ```sh
  cd iac
  terraform init
  ```

3. **Apply Terraform configurations:**
  Apply the Terraform configurations to set up the necessary AWS infrastructure:
  ```sh
  terraform apply
  ```

4. **Set environment variables:**
  Source the environment variables required for the project:
  ```sh
  source set_env_vars.sh
  ```

Once these steps are completed, you can proceed with running the PySpark scripts and Jupyter Notebooks as intended.

## Contributing
Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

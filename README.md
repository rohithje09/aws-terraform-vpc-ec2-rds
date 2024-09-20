# Terraform AWS Infrastructure Deployment

This repository contains a Terraform configuration to automate the deployment of a secure, scalable AWS infrastructure. The infrastructure includes a Virtual Private Cloud (VPC), public and private subnets, an EC2 instance with encrypted volumes, and an RDS MySQL instance, all following AWS best practices for security and optimization.

## Features
- **VPC**: A Virtual Private Cloud with both public and private subnets, designed for high availability.
- **EC2 Instance**: An EC2 instance in the private subnet with encrypted EBS volumes using AWS KMS.
- **RDS MySQL**: A MySQL RDS instance with encrypted storage using AWS KMS.
- **Security**: Configured security groups for EC2 and RDS, allowing specific IP-based access control.

## Requirements
- **AWS Account**: You'll need an AWS account with permissions to create VPC, EC2, RDS, and KMS resources.
- **Terraform**: Ensure that Terraform is installed on your machine.
- **AWS CLI**: Install and configure the AWS CLI on your local machine.

## Setup Instructions
1. **Clone the Repository**: Clone the repository to your local environment:
   ```bash
   git clone https://github.com/yourusername/terraform-aws-infra.git
   cd terraform-aws-infra

2. **Configure AWS CLI**: Run the following command to set up your AWS credentials:
   ```bash
   aws configure
3.**Update Variables**

Review and update the following variables in the `main.tf` file or create a `terraform.tfvars` file with your custom values:
- `allowed_ip`: Your public IP address for SSH access to the EC2 instance.
- `db_password`: The password for the RDS MySQL instance.
- `key_pair`: The name of your AWS EC2 key pair.

   Example `terraform.tfvars`:
   db_password = "your-db-password"
   allowed_ip  = "your-ip-address"
   key_pair    = "your-key-pair-name"

 4.** Initialize Terraform**
Run the following command to initialize your Terraform working directory:
```bash
terraform init

 5.**Plan the Infrastructure**

Preview the changes Terraform will make:
```bash
terraform plan

 6.** Deploy the Infrastructure**
Apply the configuration to create the resources:
```bash
terraform apply

 7.** Access the Resources**

After successful deployment, Terraform will output key resource details such as:
- VPC ID
- EC2 Instance ID
- RDS Endpoint

These values can be used to manage or connect to the deployed services.
 8. **Destroy the Infrastructure**

If you need to tear down the infrastructure and delete all the created resources, you can use:
```bash
terraform destroy


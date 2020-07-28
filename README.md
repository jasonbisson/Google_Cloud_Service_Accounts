# User-managed key rotation

This repository contains code for creating/deleting a service account, creating a user-managed key, destroying a key, and validating the key with a Python script listing buckets in a project. The scripts can be executed from the command line or integrated into a pipeline that can run simple bash scripts. You'll notice the absences of IAM updates from the repository, which is intentional to keep with the principle of being good at one thing. In this case, it's service account management, not IAM. Finally, there are many enterprise options, but I find this tactical option will help secure keys while enterprise options are explored.

## Install
Download the latest gcloud SDK
https://cloud.google.com/sdk/docs/

Download Git repository with sample Python code to list storage buckets
https://github.com/GoogleCloudPlatform/python-docs-samples.git

## Usage
###Creates a service account with environment name:

create_account.sh *environment* 

### Creates a user-managed key for service account with environment name and adds a new secret or adds a version to Google Secrets Manager

create_key.sh *environment*

### Deletes the oldest user-managed key and then removes the corresponding service account key stored in Secrets Manager.

delete_key.sh *environment*

### Validate user-managed key works with the latest key
Update IAM to add Storage viewer role to the new Service Account 
validate_key.sh *environment*


## External Documentation

[Understanding Service Accounts](https://cloud.google.com/iam/docs/understanding-service-accounts)

[Best practice for Managing Credentials](https://cloud.google.com/docs/authentication/production#best_practices_for_managing_credentials)

[Enterprise Secrets Management solution](https://www.hashicorp.com/products/vault/)

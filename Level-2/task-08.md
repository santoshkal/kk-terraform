# Sync Data to S3 Bucket with Terraform

As part of a data migration project, the team lead has tasked the team with migrating data from an existing S3 bucket to a new S3 bucket. The existing bucket contains a substantial amount of data that must be accurately transferred to the new bucket. The team is responsible for creating the new S3 bucket using Terraform and ensuring that all data from the existing bucket is copied or synced to the new bucket completely and accurately. It is imperative to perform thorough verification steps to confirm that all data has been successfully transferred to the new bucket without any loss or corruption.

As a member of the Nautilus DevOps Team, your task is to perform the following using Terraform:

- Create a New Private S3 Bucket: Name the bucket xfusion-sync-9623 and store this bucket name in a variable named KKE_BUCKET.

- Data Migration: Migrate all data from the existing xfusion-s3-1695 bucket to the new xfusion-sync-9623 bucket.

- Ensure Data Consistency: Ensure that both buckets contain the same data after migration.

- Update the main.tf file (do not create a separate .tf file) to provision a new private S3 bucket and migrate the data.

- Use the variables.tf file with the following variable:

    - KKE_BUCKET: The name for the new bucket created.

- Use the outputs.tf file with the following outputs:

    - new_kke_bucket_name: The name of the new bucket created.

    - new_kke_bucket_acl: The ACL of the new bucket created.


Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.

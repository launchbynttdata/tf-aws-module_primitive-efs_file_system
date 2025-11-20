# Complete example configuration for EFS File System
# This example demonstrates all available features and configurations
# Copy this file to test.tfvars and customize the values as needed

# Unique identifier for the EFS file system
creation_token = "my-complete-efs"

# (Optional) Friendly name for the EFS file system
# Will be added as a 'Name' tag for easier identification in the AWS console
name = "Complete EFS Example"

# (Optional) Specify an Availability Zone for One Zone storage class
# Leave null for Multi-AZ storage (recommended for production)
# Uncomment to use One Zone storage (lower cost, single AZ):
# availability_zone_name = "us-east-1a"

# Enable encryption at rest (recommended for production)
encrypted = true

# (Optional) KMS Key ARN for customer-managed encryption
# Leave null to use AWS managed key (aws/elasticfilesystem)
# Uncomment and provide your KMS key ARN:
# kms_key_id       = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

# Performance mode
# - generalPurpose: Lower latency, suitable for most workloads
# - maxIO: Higher throughput, suitable for highly parallelized workloads
performance_mode = "generalPurpose"

# Throughput mode
# - bursting: Scales with file system size (default)
# - elastic: Automatically scales up/down based on workload (recommended)
# - provisioned: Fixed throughput (requires provisioned_throughput_in_mibps)
throughput_mode = "elastic"

# (Optional) Provisioned throughput in MiB/s
# Only used when throughput_mode = "provisioned"
# Uncomment if using provisioned mode:
# provisioned_throughput_in_mibps = 100

# Lifecycle policy configuration
# Automatically transitions files between storage classes based on access patterns
lifecycle_policy = {
  # Move files to Infrequent Access (IA) after specified period
  # Options: AFTER_1_DAY, AFTER_7_DAYS, AFTER_14_DAYS, AFTER_30_DAYS, AFTER_60_DAYS,
  #          AFTER_90_DAYS, AFTER_180_DAYS, AFTER_270_DAYS, AFTER_365_DAYS
  transition_to_ia = "AFTER_30_DAYS"

  # Move files back to primary storage after first access
  # Options: AFTER_1_ACCESS (or null to disable)
  transition_to_primary_storage_class = "AFTER_1_ACCESS"

  # Move files to Archive storage after specified period
  # Options: Same as transition_to_ia (or null to disable)
  transition_to_archive = "AFTER_90_DAYS"
}

# Protection configuration
# Controls replication behavior
protection = {
  # Replication overwrite protection
  # Options: ENABLED, DISABLED, REPLICATING
  replication_overwrite = "DISABLED"
}

# Tags to apply to the EFS file system
tags = {
  Environment = "production"
  Example     = "complete"
  Application = "web-app"
  ManagedBy   = "Terraform"
  CostCenter  = "engineering"
}

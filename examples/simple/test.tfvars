# Example configuration for EFS File System
# Copy this file to test.tfvars and customize the values as needed

# Naming Module Configuration
logical_product_family  = "launch"
logical_product_service = "efs"
class_env               = "sandbox"
instance_env            = 1
instance_resource       = 0
region                  = "us-west-2"

# Resource names map for generating standardized names
resource_names_map = {
  efs = {
    name       = "fs"
    max_length = 60
  }
}

# Unique identifier for the EFS file system
# This should be unique within your AWS account and region
# Commented out to use generated name from resource_names module
creation_token = "simple-efs-example"

# (Optional) Friendly name for the EFS file system
# Will be added as a 'Name' tag for easier identification in the AWS console
# Commented out to use generated name from resource_names module
name = "Simple EFS Example"

# Enable encryption at rest for the EFS file system
# Set to false if encryption is not required (not recommended for production)
encrypted = true

# (Optional) KMS Key ARN for encryption
# Leave commented out to use AWS managed key (aws/elasticfilesystem)
# Uncomment and provide your KMS key ARN if using customer managed keys
# kms_key_id       = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

# Performance mode for the file system
# Options: "generalPurpose" (default, recommended for most workloads) or "maxIO" (for high throughput)
performance_mode = "generalPurpose"

# Throughput mode for the file system
# Options: "bursting" (scales with file system size) or "provisioned" (fixed throughput)
throughput_mode = "bursting"

# Tags to apply to the EFS file system
# These will be merged with default tags (ManagedBy = "Terraform")
tags = {
  Environment = "test"
  Example     = "simple"
  Purpose     = "testing"
}

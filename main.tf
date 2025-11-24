# AWS EFS File System Resource
# This module creates an AWS Elastic File System (EFS) with configurable options for encryption,
# performance, throughput, and lifecycle policies.
#
# Key Features:
# - Encryption at rest (AWS managed or customer managed KMS key)
# - Multi-AZ or One Zone storage classes
# - Configurable performance modes (generalPurpose or maxIO)
# - Flexible throughput modes (bursting, elastic, or provisioned)
# - Automated lifecycle management for cost optimization
# - Replication protection controls
resource "aws_efs_file_system" "this" {
  # Required unique identifier for the file system within the AWS account and region
  creation_token = var.creation_token

  # Optional: Specify an Availability Zone for One Zone storage (lower cost, single AZ)
  # If omitted, the file system uses Multi-AZ storage for high availability
  availability_zone_name = var.availability_zone_name

  # Encryption configuration
  encrypted  = var.encrypted
  kms_key_id = var.kms_key_id # Optional: Use customer managed KMS key, otherwise uses AWS managed key

  # Performance and throughput configuration
  performance_mode                = var.performance_mode                # generalPurpose (default) or maxIO
  throughput_mode                 = var.throughput_mode                 # bursting, elastic, or provisioned
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps # Required only for provisioned mode

  # Lifecycle Policies - Important Implementation Note:
  # AWS Provider 5.100.0 requires SEPARATE lifecycle_policy blocks for each transition type.
  # Each transition (to IA, to Archive, to Primary) must be in its own block.
  # This is different from some other AWS resources that accept all options in a single block.
  # Reference: https://registry.terraform.io/providers/hashicorp/aws/5.100.0/docs/resources/efs_file_system

  # Transition files to Infrequent Access (IA) storage class after specified period
  # Reduces storage costs for files that are not accessed frequently
  dynamic "lifecycle_policy" {
    for_each = var.lifecycle_policy != null && var.lifecycle_policy.transition_to_ia != null ? [var.lifecycle_policy.transition_to_ia] : []
    content {
      transition_to_ia = lifecycle_policy.value
    }
  }

  # Transition files back to primary storage class after first access
  # Optimizes for files that become active again after being moved to IA
  dynamic "lifecycle_policy" {
    for_each = var.lifecycle_policy != null && var.lifecycle_policy.transition_to_primary_storage_class != null ? [var.lifecycle_policy.transition_to_primary_storage_class] : []
    content {
      transition_to_primary_storage_class = lifecycle_policy.value
    }
  }

  # Transition files to Archive storage class for long-term, rarely accessed data
  # Provides the lowest cost storage option, requires transition_to_ia to be set
  # Requires Elastic throughput mode and General Purpose performance mode
  dynamic "lifecycle_policy" {
    for_each = var.lifecycle_policy != null && var.lifecycle_policy.transition_to_archive != null ? [var.lifecycle_policy.transition_to_archive] : []
    content {
      transition_to_archive = lifecycle_policy.value
    }
  }

  # Protection configuration for replication behavior
  dynamic "protection" {
    for_each = var.protection != null ? [var.protection] : []
    content {
      replication_overwrite = lookup(protection.value, "replication_overwrite", null)
    }
  }

  # Merge default tags with user-provided tags
  # Default tags include ManagedBy=Terraform and optional Name tag
  tags = local.tags
}

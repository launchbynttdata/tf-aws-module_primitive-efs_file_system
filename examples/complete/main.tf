// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Complete Example - Full-Featured EFS File System Configuration
//
// This example demonstrates all available configuration options for creating an EFS file system.
// It showcases advanced features suitable for production environments including:
// - Lifecycle policies for automatic cost optimization
// - Elastic throughput mode for automatic performance scaling
// - Protection configuration for replication control
// - Comprehensive tagging strategy
//
// Cost Optimization Strategy:
// This example implements a three-tier storage strategy:
// 1. Files are automatically moved to Infrequent Access (IA) storage after 30 days of inactivity
// 2. Files are moved to Archive storage after 90 days for long-term retention
// 3. Files are automatically moved back to Standard storage on first access for optimal performance
//
// Performance Configuration:
// - Elastic throughput mode automatically scales based on workload
// - No need to provision or manage throughput capacity
// - Pay only for actual throughput used
//
// This configuration is ideal for:
// - Production workloads with variable access patterns
// - Applications requiring cost optimization
// - Workloads with predictable lifecycle patterns (e.g., logs, archives, backups)

module "resource_names" {
  # checkov:skip=CKV_TF_1: trusted module source
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  region                  = var.region
  class_env               = var.class_env
  cloud_resource_type     = each.value.name
  instance_env            = var.instance_env
  maximum_length          = each.value.max_length
  instance_resource       = var.instance_resource
}

module "efs_complete" {
  source = "../../"

  # Unique identifier for the EFS file system within AWS account and region
  # Uses generated name from resource_names module if available, otherwise uses var.creation_token
  creation_token = try(module.resource_names["efs"].standard, var.creation_token)

  # Friendly name for AWS Console identification
  # Automatically creates a 'Name' tag
  # Uses generated name from resource_names module if available, otherwise uses var.name
  name = try(module.resource_names["efs"].standard, var.name)

  # Optional: Specify an Availability Zone for One Zone storage class
  # Leave null (default) for Multi-AZ storage with high availability
  # One Zone storage reduces costs but provides lower availability
  availability_zone_name = var.availability_zone_name

  # Encryption configuration
  # Always enable encryption for production workloads
  encrypted = var.encrypted

  # Optional: Customer managed KMS key ARN for encryption
  # Leave null to use AWS managed key (aws/elasticfilesystem)
  kms_key_id = var.kms_key_id

  # Performance mode configuration
  # - generalPurpose: Lower latency, suitable for most workloads (recommended)
  # - maxIO: Higher aggregate throughput for highly parallelized workloads
  performance_mode = var.performance_mode

  # Throughput mode configuration
  # - elastic: Automatically scales throughput based on workload (recommended for production)
  # - bursting: Throughput scales with file system size
  # - provisioned: Fixed throughput, requires provisioned_throughput_in_mibps
  throughput_mode = var.throughput_mode

  # Required only when throughput_mode = "provisioned"
  # Specifies the throughput in MiB/s to provision
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps

  # Lifecycle policy for automatic storage class transitions
  # Reduces costs by moving infrequently accessed files to lower-cost storage tiers
  # Note: Archive transitions require Elastic throughput and General Purpose performance mode
  lifecycle_policy = var.lifecycle_policy

  # Protection configuration for replication behavior
  # Controls whether replication can overwrite data in this file system
  protection = var.protection

  # Resource tags for organization, cost allocation, and compliance
  # Module automatically adds 'ManagedBy = Terraform' tag
  tags = var.tags
}

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

// Simple Example - Basic EFS File System Configuration
//
// This example demonstrates the minimal configuration needed to create an EFS file system
// with encryption enabled and default performance settings. It's suitable for:
// - Development and testing environments
// - Getting started with EFS
// - Understanding the basic required parameters
//
// Features demonstrated:
// - Encrypted EFS file system (AWS managed key)
// - General Purpose performance mode (default)
// - Bursting throughput mode (scales with file system size)
// - Basic tagging for resource identification
//
// Not included (but available in complete example):
// - Customer managed KMS key
// - Lifecycle policies for cost optimization
// - One Zone storage class
// - Elastic or provisioned throughput modes
// - Protection configuration

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

module "efs" {
  source = "../../"

  # Unique identifier for the EFS file system
  # Must be unique within your AWS account and region
  # Uses var.creation_token if provided, otherwise uses generated name from resource_names module
  creation_token = try(var.creation_token, module.resource_names["efs"].standard)

  # Optional friendly name that appears in AWS Console
  # Creates a 'Name' tag automatically
  # Uses var.name if provided, otherwise uses generated name from resource_names module
  name = try(var.name, module.resource_names["efs"].standard)

  # Enable encryption at rest using AWS managed key
  # Set to false only if encryption is not required (not recommended)
  encrypted = var.encrypted

  # KMS key for encryption (null = use AWS managed key)
  # Uncomment and provide ARN to use customer managed key
  kms_key_id = var.kms_key_id

  # Performance mode: generalPurpose (default, lower latency) or maxIO (higher throughput)
  # General Purpose is suitable for most workloads
  performance_mode = var.performance_mode

  # Throughput mode: bursting (scales with size), elastic (auto-scaling), or provisioned (fixed)
  # Bursting is cost-effective for workloads with baseline throughput needs
  throughput_mode = var.throughput_mode

  # Custom tags for resource management and cost allocation
  # Module automatically adds 'ManagedBy = Terraform' tag
  tags = var.tags
}

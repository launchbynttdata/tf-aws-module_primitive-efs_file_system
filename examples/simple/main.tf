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
module "efs" {
  source = "../../"

  # Unique identifier for the EFS file system
  # Must be unique within your AWS account and region
  creation_token = var.creation_token

  # Optional friendly name that appears in AWS Console
  # Creates a 'Name' tag automatically
  name = var.name

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

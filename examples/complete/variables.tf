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

variable "creation_token" {
  description = "A unique name used as reference when creating the EFS"
  type        = string
  default     = "my-efs-complete-example"
}

variable "name" {
  description = "Optional name for the EFS file system. If provided, will be added as a 'Name' tag"
  type        = string
  default     = "Complete EFS Example"
}

variable "availability_zone_name" {
  description = "The AWS Availability Zone in which to create the file system. Used to create a file system that uses One Zone storage classes"
  type        = string
  default     = null
}

variable "encrypted" {
  description = "If true, the disk will be encrypted"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "ARN for the KMS encryption key. If set, the EFS file system will be encrypted at rest using this key"
  type        = string
  default     = null
}

variable "performance_mode" {
  description = "The file system performance mode. Can be either 'generalPurpose' or 'maxIO'"
  type        = string
  default     = "generalPurpose"
}

variable "throughput_mode" {
  description = "Throughput mode for the file system. Valid values: 'bursting', 'provisioned', or 'elastic'"
  type        = string
  default     = "elastic"
}

variable "provisioned_throughput_in_mibps" {
  description = "The throughput, measured in MiB/s, that you want to provision for the file system. Only applicable when throughput_mode is set to 'provisioned'"
  type        = number
  default     = null
}

variable "lifecycle_policy" {
  description = "Lifecycle policy for the file system"
  type = object({
    transition_to_ia                    = optional(string)
    transition_to_primary_storage_class = optional(string)
    transition_to_archive               = optional(string)
  })
  default = {
    transition_to_ia                    = "AFTER_30_DAYS"
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
    transition_to_archive               = "AFTER_90_DAYS"
  }
}

variable "protection" {
  description = "Protection configuration for the file system"
  type = object({
    replication_overwrite = optional(string)
  })
  default = {
    replication_overwrite = "DISABLED"
  }
}

variable "tags" {
  description = "A map of tags to assign to the EFS file system"
  type        = map(string)
  default = {
    Environment = "production"
    Example     = "complete"
    Application = "web-app"
    ManagedBy   = "Terraform"
    CostCenter  = "engineering"
  }
}

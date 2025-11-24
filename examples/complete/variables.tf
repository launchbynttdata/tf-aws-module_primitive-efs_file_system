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

# Naming Module Variables
variable "logical_product_family" {
  type        = string
  description = <<EOF
    (Required) Name of the product family for which the resource is created.
    Example: org_name, department_name.
  EOF
  nullable    = false
  default     = "launch"

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_family))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }
}

variable "logical_product_service" {
  type        = string
  description = <<EOF
    (Required) Name of the product service for which the resource is created.
    For example, backend, frontend, middleware etc.
  EOF
  nullable    = false
  default     = "backend"

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_service))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }
}

variable "instance_resource" {
  type        = number
  description = "Number that represents the instance of the resource."
  default     = 0

  validation {
    condition     = var.instance_resource >= 0 && var.instance_resource <= 100
    error_message = "Instance number should be between 1 to 100."
  }
}

variable "instance_env" {
  type        = number
  description = "Number that represents the instance of the environment."
  default     = 0

  validation {
    condition     = var.instance_env >= 0 && var.instance_env <= 999
    error_message = "Instance number should be between 1 to 999."
  }
}

variable "class_env" {
  type        = string
  default     = "dev"
  description = "(Required) Environment where resource is going to be deployed. For example. dev, qa, uat"
  nullable    = false

  validation {
    condition     = length(regexall("\\b \\b", var.class_env)) == 0
    error_message = "Spaces between the words are not allowed."
  }
}

variable "resource_names_map" {
  description = "A map of key to resource_name that will be used by tf-launch-module_library-resource_name to generate resource names"
  type = map(object(
    {
      name       = string
      max_length = optional(number, 60)
    }
  ))
  default = {}
}

variable "region" {
  type        = string
  description = <<EOF
    (Required) The location where the resource will be created. Must not have spaces
    For example, us-east-1, us-west-2, eu-west-1, etc.
  EOF
  nullable    = false
  default     = "us-east-2"

  validation {
    condition     = length(regexall("\\b \\b", var.region)) == 0
    error_message = "Spaces between the words are not allowed."
  }
}

# EFS File System Variables
variable "creation_token" {
  description = "Optional unique identifier for the EFS file system. If not provided, will use the generated or provided name value"
  type        = string
  default     = null
}

variable "name" {
  description = "Optional name for the EFS file system. If not provided, a generated name from resource_names module will be used"
  type        = string
  default     = null
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
  description = "The file system performance mode. Valid values: 'generalPurpose' (default, lower latency) or 'maxIO' (higher aggregate throughput)"
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

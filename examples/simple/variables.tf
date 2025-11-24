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
  description = "Logical product family name for naming convention"
  type        = string
}

variable "logical_product_service" {
  description = "Logical product service name for naming convention"
  type        = string
}

variable "class_env" {
  description = "Environment class for naming convention (e.g., sandbox, dev, prod)"
  type        = string
}

variable "instance_env" {
  description = "Environment instance number for naming convention"
  type        = number
}

variable "instance_resource" {
  description = "Resource instance number for naming convention"
  type        = number
}

variable "region" {
  description = "AWS region for naming convention"
  type        = string
}

variable "resource_names_map" {
  description = "Map of resource types to their configurations for name generation"
  type = map(object({
    name       = string
    max_length = optional(number, 60)
  }))
  default = {}
}

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

variable "encrypted" {
  description = "If true, the disk will be encrypted"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "ARN for the KMS encryption key. Required if encrypted is true"
  type        = string
  default     = null
}

variable "performance_mode" {
  description = "The file system performance mode. Valid values: 'generalPurpose' (default, lower latency) or 'maxIO' (higher aggregate throughput)"
  type        = string
  default     = "generalPurpose"
}

variable "throughput_mode" {
  description = "Throughput mode for the file system. Valid values: 'bursting' (scales with file system size), 'elastic' (auto-scaling), or 'provisioned' (fixed throughput)"
  type        = string
  default     = "bursting"
}

variable "tags" {
  description = "A map of tags to assign to the EFS file system"
  type        = map(string)
  default = {
    Environment = "dev"
    Example     = "simple"
  }
}

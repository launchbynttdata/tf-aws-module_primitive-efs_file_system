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
  default     = "my-efs-example"
}

variable "name" {
  description = "Optional name for the EFS file system. If provided, will be added as a 'Name' tag"
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
  description = "The file system performance mode"
  type        = string
  default     = "generalPurpose"
}

variable "throughput_mode" {
  description = "Throughput mode for the file system"
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

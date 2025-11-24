variable "creation_token" {
  description = "Required unique identifier for the EFS file system. Must be unique within your AWS account and region and cannot be empty"
  type        = string
  validation {
    condition     = var.creation_token != null && var.creation_token != ""
    error_message = "Creation token is required and cannot be empty."
  }
}

variable "name" {
  description = "Required friendly name for the EFS file system. Will be added as a 'Name' tag and cannot be empty"
  type        = string
  validation {
    condition     = var.name != null && var.name != ""
    error_message = "Name is required and cannot be empty."
  }
}

variable "availability_zone_name" {
  description = "The AWS Availability Zone in which to create the file system. Used to create a file system that uses One Zone storage classes. If omitted, Multi-AZ storage will be used"
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
  description = "The file system performance mode. Valid values: 'generalPurpose' (default, lower latency for most workloads) or 'maxIO' (higher aggregate throughput for highly parallelized workloads)"
  type        = string
  default     = "generalPurpose"
  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.performance_mode)
    error_message = "Performance mode must be either 'generalPurpose' or 'maxIO'."
  }
}

variable "throughput_mode" {
  description = "Throughput mode for the file system. Valid values: 'bursting' (scales with file system size), 'elastic' (automatically scales based on workload), or 'provisioned' (fixed throughput - requires provisioned_throughput_in_mibps to be set)"
  type        = string
  default     = "bursting"
  validation {
    condition     = contains(["bursting", "provisioned", "elastic"], var.throughput_mode)
    error_message = "Throughput mode must be 'bursting', 'provisioned', or 'elastic'."
  }
}

variable "provisioned_throughput_in_mibps" {
  description = "The throughput, measured in MiB/s, that you want to provision for the file system. Only applicable when throughput_mode is set to 'provisioned'"
  type        = number
  default     = null
}

variable "lifecycle_policy" {
  description = "Lifecycle policy for the file system. Supports transition_to_ia (AFTER_7_DAYS, AFTER_14_DAYS, AFTER_30_DAYS, AFTER_60_DAYS, AFTER_90_DAYS, AFTER_1_DAY, AFTER_180_DAYS, AFTER_270_DAYS, AFTER_365_DAYS), transition_to_primary_storage_class (AFTER_1_ACCESS), and transition_to_archive (AFTER_1_DAY, AFTER_7_DAYS, AFTER_14_DAYS, AFTER_30_DAYS, AFTER_60_DAYS, AFTER_90_DAYS, AFTER_180_DAYS, AFTER_270_DAYS, AFTER_365_DAYS)"
  type = object({
    transition_to_ia                    = optional(string)
    transition_to_primary_storage_class = optional(string)
    transition_to_archive               = optional(string)
  })
  default = null
}

variable "protection" {
  description = "Protection configuration for the file system. Supports replication_overwrite (ENABLED, DISABLED, REPLICATING)"
  type = object({
    replication_overwrite = optional(string)
  })
  default = null
}

variable "tags" {
  description = "A map of tags to assign to the EFS file system"
  type        = map(string)
  default     = {}
}

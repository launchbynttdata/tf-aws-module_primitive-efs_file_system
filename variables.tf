variable "creation_token" {
  description = "A unique name used as reference when creating the EFS"
  type        = string
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
  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.performance_mode)
    error_message = "Performance mode must be either 'generalPurpose' or 'maxIO'."
  }
}

variable "throughput_mode" {
  description = "Throughput mode for the file system"
  type        = string
  default     = "bursting"
  validation {
    condition     = contains(["bursting", "provisioned"], var.throughput_mode)
    error_message = "Throughput mode must be either 'bursting' or 'provisioned'."
  }
}

variable "tags" {
  description = "A map of tags to assign to the EFS file system"
  type        = map(string)
  default     = {}
}

# EFS File System Outputs
#
# Note: This module intentionally exposes only static outputs that are directly derived from
# input variables or guaranteed to be available at plan time. Dynamic/computed outputs such as
# availability_zone_id, availability_zone_name, number_of_mount_targets, owner_id, and
# size_in_bytes have been removed because they can cause idempotency issues when this primitive
# module is used in collection modules. These computed values change independently of input
# changes and can trigger unnecessary plan differences in parent modules.
#
# If you need access to these dynamic values, you can query them directly using the AWS SDK
# or AWS CLI after the resource is created, rather than exposing them as module outputs.

output "file_system_id" {
  description = "The ID of the EFS file system"
  value       = aws_efs_file_system.this.id
}

output "file_system_arn" {
  description = "Amazon Resource Name of the file system"
  value       = aws_efs_file_system.this.arn
}

output "file_system_dns_name" {
  description = "The DNS name for the filesystem"
  value       = aws_efs_file_system.this.dns_name
}

output "file_system_creation_token" {
  description = "The creation token of the EFS file system"
  value       = aws_efs_file_system.this.creation_token
}

output "file_system_name" {
  description = "The value of the file system's Name tag"
  value       = aws_efs_file_system.this.name
}

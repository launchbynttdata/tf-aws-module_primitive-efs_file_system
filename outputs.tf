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

output "file_system_availability_zone_id" {
  description = "The identifier of the Availability Zone in which the file system's One Zone storage classes exist"
  value       = aws_efs_file_system.this.availability_zone_id
}

output "file_system_availability_zone_name" {
  description = "The Availability Zone name in which the file system's One Zone storage classes exist"
  value       = aws_efs_file_system.this.availability_zone_name
}

output "file_system_number_of_mount_targets" {
  description = "The current number of mount targets that the file system has"
  value       = aws_efs_file_system.this.number_of_mount_targets
}

output "file_system_owner_id" {
  description = "The AWS account that created the file system"
  value       = aws_efs_file_system.this.owner_id
}

output "file_system_size_in_bytes" {
  description = "The latest known metered size (in bytes) of data stored in the file system"
  value       = aws_efs_file_system.this.size_in_bytes
}

output "file_system_name" {
  description = "The value of the file system's Name tag"
  value       = aws_efs_file_system.this.name
}

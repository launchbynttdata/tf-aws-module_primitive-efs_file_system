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
resource "aws_efs_file_system" "this" {
  creation_token   = var.creation_token
  encrypted        = var.encrypted
  kms_key_id       = var.kms_key_id
  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode

  tags = local.tags
}
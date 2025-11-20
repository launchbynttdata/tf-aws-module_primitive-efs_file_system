# Simple EFS Example - Test Configuration
# This file contains test values for the simple example configuration.
# It demonstrates a minimal, working EFS setup suitable for development and testing.

# Unique identifier for the EFS file system
# Must be unique within your AWS account and region
# Update this value to avoid conflicts with existing file systems
creation_token = "jwidby-sand-test"

# Friendly name displayed in AWS Console
# Creates a 'Name' tag for easy identification
name = "Simple EFS Example"

# Enable encryption at rest
# Uses AWS managed key (aws/elasticfilesystem) by default
# Set to false only if encryption is not required (not recommended for production)
encrypted = true

# Performance mode: generalPurpose or maxIO
# General Purpose provides lower latency and is suitable for most workloads
# Use maxIO only for highly parallelized workloads requiring maximum throughput
performance_mode = "generalPurpose"

# Throughput mode: bursting, elastic, or provisioned
# Bursting scales throughput with file system size
# This is cost-effective for workloads with baseline throughput requirements
throughput_mode = "bursting"

# Resource tags for organization and cost tracking
# Module automatically adds 'ManagedBy = Terraform' tag
tags = {
  Environment = "test"
  Example     = "simple"
  Purpose     = "testing"
}

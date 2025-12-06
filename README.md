# tf-aws-module_primitive-efs_file_system

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

A Terraform primitive module for creating and managing AWS Elastic File System (EFS) file systems. This module provides a standardized way to create EFS file systems with configurable encryption, performance modes, throughput settings, and lifecycle policies for cost optimization.

## Features

- **Encryption at Rest**: Supports both AWS managed and customer managed KMS keys
- **Flexible Storage Options**: Multi-AZ (high availability) or One Zone (cost optimized) storage classes
- **Performance Modes**: Choose between General Purpose (lower latency) or Max I/O (higher throughput)
- **Throughput Modes**: Bursting, Elastic (auto-scaling), or Provisioned throughput
- **Lifecycle Management**: Automated transitions between storage classes (Standard, IA, Archive) for cost optimization
- **Protection Controls**: Configurable replication overwrite protection
- **Comprehensive Tagging**: Support for custom tags with automatic ManagedBy tag and optional Name tag
- **Input Validation**: Built-in validation for performance mode and throughput mode values

## Recent Changes

### Output Optimization (Breaking Change)
To prevent idempotency issues when this module is used in collection modules, the following computed/dynamic outputs have been removed:
- `file_system_availability_zone_id`
- `file_system_availability_zone_name`
- `file_system_number_of_mount_targets`
- `file_system_owner_id`
- `file_system_size_in_bytes`

These values change independently of input variables and can cause unnecessary plan differences in parent modules. If you need these values, query them directly using the AWS SDK or CLI after resource creation.

### Dependency Updates
- **Go**: Updated to version 1.25.4
- **AWS SDK for Go v2**: Updated to latest versions for improved performance and security
  - `aws-sdk-go-v2` v1.40.1
  - `aws-sdk-go-v2/service/efs` v1.41.7
- **Terratest**: Updated to v0.54.0
- **LCAF Testing Library**: Updated to v1.0.4

## Usage

### Basic Example

```hcl
module "efs" {
  source = "github.com/launchbynttdata/tf-aws-module_primitive-efs_file_system?ref=1.0.0"

  creation_token = "my-app-efs"
  name           = "My Application EFS"
  encrypted      = true

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

### Complete Example with All Features

```hcl
module "efs" {
  source = "github.com/launchbynttdata/tf-aws-module_primitive-efs_file_system?ref=1.0.0"

  creation_token   = "my-app-efs"
  name             = "Production EFS"
  encrypted        = true
  kms_key_id       = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"

  # Cost optimization with lifecycle policies
  lifecycle_policy = {
    transition_to_ia                    = "AFTER_30_DAYS"
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
    transition_to_archive               = "AFTER_90_DAYS"
  }

  protection = {
    replication_overwrite = "DISABLED"
  }

  tags = {
    Environment = "production"
    Application = "my-app"
    CostCenter  = "engineering"
  }
}
```

### One Zone Storage Example

```hcl
module "efs_one_zone" {
  source = "github.com/launchbynttdata/tf-aws-module_primitive-efs_file_system?ref=1.0.0"

  creation_token         = "my-dev-efs"
  name                   = "Development EFS"
  availability_zone_name = "us-east-1a"  # Creates One Zone storage
  encrypted              = true
  throughput_mode        = "bursting"

  tags = {
    Environment = "development"
  }
}
```

## Important Notes

### Lifecycle Policy Implementation

This module uses **separate `lifecycle_policy` blocks** for each transition type as required by AWS Provider version 5.100.0. Each transition rule (to IA, to Archive, to Primary Storage) must be defined in its own block. See the [main.tf](main.tf) file for detailed implementation comments.

### Mount Targets

This module creates only the EFS file system resource itself. To mount the file system to EC2 instances or other compute resources, you'll need to create EFS mount targets separately using a mount target module or resource. Mount targets require:
- VPC subnet IDs
- Security groups for access control
- Network connectivity to your compute resources

### Storage Classes and Cost Optimization

- **Standard**: Default storage class for frequently accessed files
- **Infrequent Access (IA)**: Lower cost for files accessed less frequently
- **Archive**: Lowest cost for long-term storage, rarely accessed files
- Use lifecycle policies to automatically transition files between storage classes based on access patterns

### Throughput Modes

- **Bursting**: Throughput scales with file system size (good for baseline workloads)
- **Elastic**: Automatically scales throughput up/down based on workload (recommended for variable workloads)
- **Provisioned**: Fixed throughput independent of storage size (use when you need guaranteed throughput)

Install required development dependencies:

```bash
make configure-dependencies
make configure-git-hooks
```

This installs:

- Terraform
- Go
- Pre-commit hooks
- Other development tools specified in `.tool-versions`

---

## HOWTO: Developing a Primitive Module

### Step 1: Define Your Resource

1. **Identify the AWS resource** you're wrapping (e.g., `aws_eks_cluster`)
2. **Review AWS documentation** for the resource to understand all available parameters
3. **Study similar primitive modules** for patterns and best practices

### Step 2: Create the Module Structure

Your primitive module should include these core files:

#### `main.tf`

- Contains the primary resource declaration
- Should be clean and focused on the single resource
- Example:

```hcl
resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = var.role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.vpc_config.subnet_ids
    security_group_ids      = var.vpc_config.security_group_ids
    endpoint_private_access = var.vpc_config.endpoint_private_access
    endpoint_public_access  = var.vpc_config.endpoint_public_access
    public_access_cidrs     = var.vpc_config.public_access_cidrs
  }

  tags = merge(
    var.tags,
    local.default_tags
  )
}
```

#### `variables.tf`

- Define all configurable parameters
- Include clear descriptions for each variable
- Set sensible defaults where appropriate
- Use validation rules to enforce constraints, but only when the validations can be made precise.
- Alternatively, use [`check`](https://developer.hashicorp.com/terraform/language/block/check) blocks to create more complicated validations. (Requires terraform ~> 1.12)
- Example:

```hcl
variable "name" {
  description = "Name of the EKS cluster"
  type        = string

  validation {
    condition     = length(var.name) <= 100
    error_message = "Cluster name must be 100 characters or less"
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = null

  validation {
    condition     = var.kubernetes_version == null || can(regex("^1\\.(2[89]|[3-9][0-9])$", var.kubernetes_version))
    error_message = "Kubernetes version must be 1.28 or higher"
  }
}
```

#### `outputs.tf`

- Export all useful attributes of the resource
- Include comprehensive outputs for downstream consumption
- Document what each output provides
- Example:

```hcl
output "id" {
  description = "The ID of the EKS cluster"
  value       = aws_eks_cluster.this.id
}

output "arn" {
  description = "The ARN of the EKS cluster"
  value       = aws_eks_cluster.this.arn
}

output "endpoint" {
  description = "The endpoint for the EKS cluster API server"
  value       = aws_eks_cluster.this.endpoint
}
```

#### `locals.tf`

- Define local values and transformations
- Include standard tags (e.g., `provisioner = "Terraform"`)
- Example:

```hcl
locals {
  default_tags = {
    provisioner = "Terraform"
  }
}
```

#### `versions.tf`

- Specify required Terraform and provider versions
- Example:

```hcl
terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100"
    }
  }
}
```

### Step 3: Create Examples

Create example configurations in the `examples/` directory:

#### `examples/simple/`

- Minimal, working configuration
- Uses only required variables
- Good for quick starts and basic testing

#### `examples/complete/`

- Comprehensive configuration showing all features
- Demonstrates advanced options
- Includes comments explaining choices

Each example should include:

- `main.tf` - The module invocation
- `variables.tf` - Example variables
- `outputs.tf` - Pass-through outputs
- `test.tfvars` - Test values for automated testing
- `README.md` - Documentation for the example

### Step 4: Write Tests

Update the test files in `tests/`:

#### `tests/testimpl/test_impl.go`

Write functional tests that verify:

- The resource is created successfully
- Resource properties match expectations
- Outputs are correct
- Integration with AWS SDK to verify actual state

#### `tests/testimpl/types.go`

Define the configuration structure for your tests:

```go
type ThisTFModuleConfig struct {
    Name              string `json:"name"`
    KubernetesVersion string `json:"kubernetes_version"`
    // ... other fields
}
```

#### `tests/post_deploy_functional/main_test.go`

- Update test names to match your module
- Configure test flags (e.g., idempotency settings)
- Adjust test context as needed

### Step 5: Update Documentation

1. **Update README.md** with:
   - Overview of the module
   - Feature list
   - Usage examples
   - Input/output documentation
   - Validation rules

2. **Document validation rules** clearly so users understand constraints.

### Step 6: Test Your Module

1. **Run local validation**:

```bash
make check
```

This runs:

- Terraform fmt, validate, and plan
- Go tests with Terratest
- Pre-commit hooks
- Security scans

1. **Test with real infrastructure**:

```bash
cd examples/simple
terraform init
terraform plan -var-file=test.tfvars -out=the.tfplan
terraform apply the.tfplan
```

1. **Verify outputs**:

```bash
terraform output
```

1. **Clean up**:

```bash
terraform destroy -var-file=test.tfvars
```

### Step 7: Document and Release

1. **Write a comprehensive README** following the pattern in the example modules
1. **Add files to commit** `git add .`
1. **Run pre-commit hooks manually** `pre-commit run`
1. **Resolve any pre-commit issues**
1. **Push branch to github**

---

## Module Best Practices

### Naming Conventions

- Repository: `tf-aws-module_primitive-<resource_name>`
- Resource identifier: Use `this` for the primary resource.
- Variables: Use snake_case.
- Match AWS resource parameter names where possible.

### Input Variables

- Provide sensible defaults when safe to do so.
- Use `null` as default for optional complex objects.
- Include validation rules with clear error messages.
- Group related parameters using object types.
- Document expected formats and constraints.

### Outputs

- Export all significant resource attributes.
- Use clear, descriptive output names.
- Include descriptions for all outputs.
- Consider downstream module needs.
- **Avoid computed/dynamic outputs** that change independently of input changes, as these can cause idempotency issues when this module is used in collection modules. Only expose static outputs that are directly derived from input variables.

### Tags

- Always include a `tags` variable, unless the resource does not support tags.
- Merge with `local.default_tags` including `provisioner = "Terraform"`.
- Use provider default tags when appropriate.

### Validation

- Validate input constraints at the variable level.
- Provide helpful error messages.
- Check for common misconfigurations.
- Validate relationships between variables.

### Testing

- Test the minimal example (required parameters only).
- Test the complete example (all features).
- Verify resource creation and properties.
- Test idempotency where applicable.
- Test validation rules by expecting failures.

### Documentation

- Clear overview of the module's purpose.
- Feature list highlighting key capabilities.
- Multiple usage examples (minimal and complete).
- Comprehensive input/output tables.
- Document validation rules and constraints.
- Include links to relevant AWS documentation.

---

## File Structure

After initialization, your module should have this structure:

```
tf-aws-module_primitive-<resource_name>/
├── .github/
│   └── workflows/          # CI/CD workflows
├── examples/
│   ├── simple/            # Minimal example
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── test.tfvars
│   │   └── README.md
│   └── complete/          # Comprehensive example
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── test.tfvars
│       └── README.md
├── tests/
│   ├── post_deploy_functional/
│   │   └── main_test.go
│   ├── testimpl/
│   │   ├── test_impl.go
│   │   └── types.go
├── .gitignore
├── .pre-commit-config.yaml
├── .tool-versions
├── go.mod
├── go.sum
├── LICENSE
├── locals.tf
├── main.tf
├── Makefile
├── outputs.tf
├── README.md
├── variables.tf
└── versions.tf
```

---

## Common Makefile Targets

| Target | Description |
|--------|-------------|
| `make init-module` | Initialize new module from template (run once after creating from template) |
| `make configure-dependencies` | Install required development tools |
| `make configure-git-hooks` | Set up pre-commit hooks |
| `make check` | Run all validation and tests |
| `make configure` | Full setup (dependencies + hooks + repo sync) |
| `make clean` | Remove downloaded components |

---

## Getting Help

- Review example modules: [EKS Cluster](https://github.com/launchbynttdata/tf-aws-module_primitive-eks_cluster), [KMS Key](https://github.com/launchbynttdata/tf-aws-module_primitive-kms_key)
- Check the Launch Common Automation Framework documentation.
- Reach out to the platform team for guidance.

---

## Contributing

Follow the established patterns in existing primitive modules. All modules should:

- Pass `make check` validation.
- Include comprehensive tests.
- Follow naming conventions.
- Include clear documentation.
- Use semantic versioning.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.100 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_efs_file_system.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_creation_token"></a> [creation\_token](#input\_creation\_token) | Required unique identifier for the EFS file system. Must be unique within your AWS account and region and cannot be empty | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Required friendly name for the EFS file system. Will be added as a 'Name' tag and cannot be empty | `string` | n/a | yes |
| <a name="input_availability_zone_name"></a> [availability\_zone\_name](#input\_availability\_zone\_name) | The AWS Availability Zone in which to create the file system. Used to create a file system that uses One Zone storage classes. If omitted, Multi-AZ storage will be used | `string` | `null` | no |
| <a name="input_encrypted"></a> [encrypted](#input\_encrypted) | If true, the disk will be encrypted | `bool` | `true` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN for the KMS encryption key. If set, the EFS file system will be encrypted at rest using this key | `string` | `null` | no |
| <a name="input_performance_mode"></a> [performance\_mode](#input\_performance\_mode) | The file system performance mode. Valid values: 'generalPurpose' (default, lower latency for most workloads) or 'maxIO' (higher aggregate throughput for highly parallelized workloads) | `string` | `"generalPurpose"` | no |
| <a name="input_throughput_mode"></a> [throughput\_mode](#input\_throughput\_mode) | Throughput mode for the file system. Valid values: 'bursting' (scales with file system size), 'elastic' (automatically scales based on workload), or 'provisioned' (fixed throughput - requires provisioned\_throughput\_in\_mibps to be set) | `string` | `"bursting"` | no |
| <a name="input_provisioned_throughput_in_mibps"></a> [provisioned\_throughput\_in\_mibps](#input\_provisioned\_throughput\_in\_mibps) | The throughput, measured in MiB/s, that you want to provision for the file system. Only applicable when throughput\_mode is set to 'provisioned' | `number` | `null` | no |
| <a name="input_lifecycle_policy"></a> [lifecycle\_policy](#input\_lifecycle\_policy) | Lifecycle policy for the file system. Supports transition\_to\_ia (AFTER\_7\_DAYS, AFTER\_14\_DAYS, AFTER\_30\_DAYS, AFTER\_60\_DAYS, AFTER\_90\_DAYS, AFTER\_1\_DAY, AFTER\_180\_DAYS, AFTER\_270\_DAYS, AFTER\_365\_DAYS), transition\_to\_primary\_storage\_class (AFTER\_1\_ACCESS), and transition\_to\_archive (AFTER\_1\_DAY, AFTER\_7\_DAYS, AFTER\_14\_DAYS, AFTER\_30\_DAYS, AFTER\_60\_DAYS, AFTER\_90\_DAYS, AFTER\_180\_DAYS, AFTER\_270\_DAYS, AFTER\_365\_DAYS) | <pre>object({<br/>    transition_to_ia                    = optional(string)<br/>    transition_to_primary_storage_class = optional(string)<br/>    transition_to_archive               = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_protection"></a> [protection](#input\_protection) | Protection configuration for the file system. Supports replication\_overwrite (ENABLED, DISABLED, REPLICATING) | <pre>object({<br/>    replication_overwrite = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the EFS file system | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_file_system_id"></a> [file\_system\_id](#output\_file\_system\_id) | The ID of the EFS file system |
| <a name="output_file_system_arn"></a> [file\_system\_arn](#output\_file\_system\_arn) | Amazon Resource Name of the file system |
| <a name="output_file_system_dns_name"></a> [file\_system\_dns\_name](#output\_file\_system\_dns\_name) | The DNS name for the filesystem |
| <a name="output_file_system_creation_token"></a> [file\_system\_creation\_token](#output\_file\_system\_creation\_token) | The creation token of the EFS file system |
| <a name="output_file_system_availability_zone_id"></a> [file\_system\_availability\_zone\_id](#output\_file\_system\_availability\_zone\_id) | The identifier of the Availability Zone in which the file system's One Zone storage classes exist |
| <a name="output_file_system_availability_zone_name"></a> [file\_system\_availability\_zone\_name](#output\_file\_system\_availability\_zone\_name) | The Availability Zone name in which the file system's One Zone storage classes exist |
| <a name="output_file_system_name"></a> [file\_system\_name](#output\_file\_system\_name) | The value of the file system's Name tag |
<!-- END_TF_DOCS -->

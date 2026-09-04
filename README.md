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
  availability_zone_name = "us-east-1a"
  encrypted              = true
  throughput_mode        = "bursting"

  tags = {
    Environment = "development"
  }
}
```

## Examples

See [examples/complete](./examples/complete) and [examples/simple](./examples/simple).

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
| <a name="input_lifecycle_policy"></a> [lifecycle\_policy](#input\_lifecycle\_policy) | Lifecycle policy for the file system. | <pre>object({<br/>    transition_to_ia                    = optional(string)<br/>    transition_to_primary_storage_class = optional(string)<br/>    transition_to_archive               = optional(string)<br/>  })</pre> | `null` | no |
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

## Module Development

### Pre-Requisites

The following commands should be available on your system:

- `asdf` or `mise`
- `make`
- `python3` (for pre-commit)

Additionally, your `git` user and email must be configured. Run the `make configure` command from the root of the repository to ensure that you meet these requirements.

### Pre-Commit hooks

The [.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to Terraform and Golang, as well as some common linting tasks. These will be configured for you when you run `make configure`.

### Local Validation

You should validate the changes you make to any module locally, prior to pushing your changes in a branch to GitHub.

1. Ensure that you have run `make configure` successfully.

2. Ensure you are signed into the appropriate cloud provider (e.g. AWS or Azure) for the module under test in your current console session.

3. Run the Terraform and Golang linters with the following command:

```
make lint
```

4. Once you have satisfied the linters, the following command will build example infrastructure in your configured cloud, run the tests, and then tear down the infrastructure it created:

```
make test
```

The pre-commit validations, as well as the `make lint` and `make test` targets, will all be performed in CI. Running these validations locally prior to opening a PR helps ensure a smooth review and merge process.

### Review & Merge Process

Once your change has been tested locally and your branch pushed up, open a new Pull Request for your branch to the default (main) branch of this repository.

The title of your Pull Request will determine the version bump for this change, and the title must be in [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#specification) format in order to merge. A breaking change will trigger a major version bump, a feature will trigger a minor version bump, and all other types will trigger a patch version bump.

Ensure your CI workflows are passing; seek approval from teammates and address any feedback; seek any explicit approvals required by the CODEOWNERS file. You may merge the PR as soon as all requirements are met, and a new release and tag will be automatically created for you.

### Automatic Updates

The shared configuration and workflow files in this repository are largely managed through the [launch-terraform-skeleton](https://github.com/launchbynttdata/launch-terraform-skeleton) repository. Outside of perhaps the `.gitignore` to account for specific files being generated by certain Terraform modules (e.g. Lambda functions), there should not be much cause to update these files on a per-repo basis, and making changes to them individually is discouraged.

If desired, you can check for and run these updates locally in a branch if you have the `copier` tool installed. Some example commands are included below:

```
# Check for updates, optionally checking prerelease versions
copier check-update [--prereleases]

# Run an update, using default answers if there are any. We use tasks, which requires --trust to be set.
copier update --defaults --trust [--prereleases]

# Recopy from the source, and --overwrite all templated files in the process
copier recopy --defaults --trust --overwrite [--prereleases]
```

Automatic updates will run through a scheduled workflow, and if the post-update tests are successful, the Pull Request created will automatically merge. Conflicts in the update or failures to test may leave a Pull Request outstanding, which needs to be addressed by a Launch Engineer.

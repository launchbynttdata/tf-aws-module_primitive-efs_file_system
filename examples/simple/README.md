# Simple Example

This example provides a minimal, working configuration for the `tf-aws-module_primitive-efs_file_system` module. It demonstrates the basic required parameters to create an encrypted EFS file system suitable for development and testing environments.

## Purpose

This example is designed for:
- **Getting started** with AWS EFS and this module
- **Development and testing** environments where cost optimization is less critical
- **Learning** the basic configuration parameters
- **Integration testing** of the module functionality

## What This Example Demonstrates

### Core Features
- ✅ **Encryption at Rest**: Uses AWS managed key (no additional cost)
- ✅ **General Purpose Performance**: Lower latency suitable for most workloads
- ✅ **Bursting Throughput**: Scales with file system size automatically
- ✅ **Basic Tagging**: Simple tag structure for resource identification
- ✅ **Name Tag**: Friendly name for easy identification in AWS Console

### What's Not Included
This simple example intentionally excludes advanced features to keep the configuration minimal:
- ❌ Customer managed KMS keys
- ❌ Lifecycle policies (cost optimization)
- ❌ One Zone storage (single AZ)
- ❌ Elastic or provisioned throughput modes
- ❌ Protection configuration

For a comprehensive example with all features, see the [complete example](../complete/).

## Architecture

```
┌─────────────────────────────────────┐
│   AWS Elastic File System (EFS)     │
│                                     │
│  • Multi-AZ Storage                 │
│  • AWS Managed Encryption           │
│  • General Purpose Performance      │
│  • Bursting Throughput             │
│  • Standard Storage Class Only      │
└─────────────────────────────────────┘
```

## Usage

### Prerequisites
- AWS credentials configured
- Terraform ~> 1.0 installed

### Deploy

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan -var-file=test.tfvars

# Apply the configuration
terraform apply -var-file=test.tfvars

# View outputs
terraform output
```

### Clean Up

```bash
terraform destroy -var-file=test.tfvars
```

## Configuration

The example uses default values for most parameters. To customize:

1. **Update `test.tfvars`** with your values:
   ```hcl
   creation_token = "my-unique-efs-name"
   name           = "My Development EFS"
   ```

2. **Optionally modify `variables.tf`** to change defaults

3. **Review and apply** the changes

## Expected Outputs

After successful deployment, you'll receive:

- `file_system_id`: EFS file system ID (e.g., `fs-12345678`)
- `file_system_arn`: Full ARN of the file system
- `file_system_dns_name`: DNS name for mounting (e.g., `fs-12345678.efs.us-east-1.amazonaws.com`)
- `file_system_creation_token`: The unique creation token
- `file_system_name`: The friendly name assigned to the file system

**Note**: Dynamic computed outputs (such as availability zones, mount target count, owner ID, and size in bytes) have been intentionally removed to prevent idempotency issues when this module is used in collection modules.

## Next Steps

After creating the EFS file system:

1. **Create mount targets** in your VPC subnets (not included in this module)
2. **Configure security groups** to allow NFS traffic (port 2049)
3. **Mount the file system** to your EC2 instances or containers
4. **Consider the complete example** for production use with cost optimization

## Cost Estimation

This simple configuration will incur:
- **Storage costs**: ~$0.30/GB-month (Standard storage class)
- **No throughput costs** with bursting mode
- **No data transfer costs** within the same AZ

For cost optimization with lifecycle policies, see the [complete example](../complete/).

## Resources Created

- **1 EFS File System** with:
  - Encryption enabled (AWS managed key)
  - Multi-AZ storage for high availability
  - General Purpose performance mode
  - Bursting throughput mode
  - Name tag for easy identification

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.100 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_efs"></a> [efs](#module\_efs) | ../../ | n/a |
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | Environment class for naming convention (e.g., sandbox, dev, prod) | `string` | n/a | yes |
| <a name="input_creation_token"></a> [creation\_token](#input\_creation\_token) | Optional unique identifier for the EFS file system. If not provided, will use the generated or provided name value | `string` | `null` | no |
| <a name="input_encrypted"></a> [encrypted](#input\_encrypted) | If true, the disk will be encrypted | `bool` | `true` | no |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Environment instance number for naming convention | `number` | n/a | yes |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Resource instance number for naming convention | `number` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN for the KMS encryption key. Required if encrypted is true | `string` | `null` | no |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | Logical product family name for naming convention | `string` | n/a | yes |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | Logical product service name for naming convention | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Optional name for the EFS file system. If not provided, a generated name from resource\_names module will be used | `string` | `null` | no |
| <a name="input_performance_mode"></a> [performance\_mode](#input\_performance\_mode) | The file system performance mode. Valid values: 'generalPurpose' (default, lower latency) or 'maxIO' (higher aggregate throughput) | `string` | `"generalPurpose"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region for naming convention | `string` | n/a | yes |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | Map of resource types to their configurations for name generation | <pre>map(object({<br/>    name       = string<br/>    max_length = optional(number, 60)<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the EFS file system | `map(string)` | <pre>{<br/>  "Environment": "dev",<br/>  "Example": "simple"<br/>}</pre> | no |
| <a name="input_throughput_mode"></a> [throughput\_mode](#input\_throughput\_mode) | Throughput mode for the file system. Valid values: 'bursting' (scales with file system size), 'elastic' (auto-scaling), or 'provisioned' (fixed throughput) | `string` | `"bursting"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_file_system_arn"></a> [file\_system\_arn](#output\_file\_system\_arn) | Amazon Resource Name of the file system |
| <a name="output_file_system_availability_zone_id"></a> [file\_system\_availability\_zone\_id](#output\_file\_system\_availability\_zone\_id) | The identifier of the Availability Zone in which the file system's One Zone storage classes exist |
| <a name="output_file_system_availability_zone_name"></a> [file\_system\_availability\_zone\_name](#output\_file\_system\_availability\_zone\_name) | The Availability Zone name in which the file system's One Zone storage classes exist |
| <a name="output_file_system_creation_token"></a> [file\_system\_creation\_token](#output\_file\_system\_creation\_token) | The creation token of the EFS file system |
| <a name="output_file_system_dns_name"></a> [file\_system\_dns\_name](#output\_file\_system\_dns\_name) | The DNS name for the filesystem |
| <a name="output_file_system_id"></a> [file\_system\_id](#output\_file\_system\_id) | The ID of the EFS file system |
| <a name="output_file_system_name"></a> [file\_system\_name](#output\_file\_system\_name) | The value of the file system's Name tag |
<!-- END_TF_DOCS -->

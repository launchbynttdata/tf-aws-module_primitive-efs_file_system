# Complete Example

This example demonstrates **all available features** and configurations of the `tf-aws-module_primitive-efs_file_system` module. It showcases a production-ready setup with advanced cost optimization, performance tuning, and protection features suitable for enterprise workloads.

## Purpose

This example is designed for:
- **Production deployments** requiring cost optimization and performance tuning
- **Understanding all module capabilities** and configuration options
- **Learning best practices** for EFS lifecycle management
- **Reference implementation** for enterprise use cases

## What This Example Demonstrates

### Cost Optimization Features
- ✅ **Lifecycle Policies**: Automatic transitions between storage classes
  - Standard → Infrequent Access (IA) after 30 days
  - IA → Archive after 90 days for long-term retention
  - Automatic return to Standard on first access
- ✅ **Elastic Throughput**: Pay only for actual throughput used
- ✅ **Storage Class Intelligence**: Can save up to 95% on storage costs

### Performance Features
- ✅ **Elastic Throughput Mode**: Automatic performance scaling
- ✅ **General Purpose Performance**: Optimized for latency-sensitive workloads
- ✅ **Multi-AZ Storage**: High availability across multiple zones

### Security & Protection
- ✅ **Encryption at Rest**: AWS or customer managed KMS keys
- ✅ **Protection Configuration**: Replication overwrite controls
- ✅ **Comprehensive Tagging**: Cost allocation and compliance tracking

### Additional Capabilities
- ✅ **One Zone Storage Option**: Cost-optimized single-AZ deployment
- ✅ **Provisioned Throughput**: Fixed performance for predictable workloads
- ✅ **All Available Outputs**: Complete observability and integration

## Architecture

```
┌───────────────────────────────────────────────────────────┐
│         AWS Elastic File System (EFS)                     │
│                                                           │
│  Storage Tiers (Automatic Lifecycle Transitions):        │
│  ┌─────────────┐  30 days   ┌────────────────┐          │
│  │   Standard  │────────────→│ Infrequent     │          │
│  │   Storage   │←────────────│ Access (IA)    │          │
│  │  ($0.30/GB) │  1st access │   ($0.025/GB)  │          │
│  └─────────────┘             └────────┬───────┘          │
│                                90 days│                   │
│                               ┌───────▼────────┐          │
│                               │    Archive     │          │
│                               │   ($0.016/GB)  │          │
│                               └────────────────┘          │
│                                                           │
│  Performance:                                             │
│  • Elastic Throughput (Auto-scaling)                     │
│  • General Purpose Mode                                   │
│  • Multi-AZ High Availability                            │
└───────────────────────────────────────────────────────────┘
```

## Cost Optimization Strategy

This example implements a **three-tier storage strategy** that can reduce storage costs by up to **95%**:

| Storage Class | Cost/GB-Month | Use Case | Transition |
|--------------|---------------|----------|------------|
| **Standard** | ~$0.30 | Active files | Default |
| **Infrequent Access** | ~$0.025 | Files not accessed for 30 days | Automatic |
| **Archive** | ~$0.016 | Long-term retention (90+ days) | Automatic |

### Example Savings

For a 1TB file system where:
- 20% (200GB) files are actively used → Standard: $60/month
- 30% (300GB) files accessed occasionally → IA: $7.50/month
- 50% (500GB) files are archived → Archive: $8/month

**Total: $75.50/month vs $300/month (75% savings)**

## Configuration Options Demonstrated

### 1. Storage Classes and Lifecycle Management

Automatic cost optimization through intelligent data tiering:

```hcl
lifecycle_policy = {
  transition_to_ia                    = "AFTER_30_DAYS"    # 92% cost reduction
  transition_to_primary_storage_class = "AFTER_1_ACCESS"   # Performance on demand
  transition_to_archive               = "AFTER_90_DAYS"    # 95% cost reduction
}
```

### 2. Throughput Modes Comparison

| Mode | Best For | Cost Model | Configuration |
|------|----------|------------|---------------|
| **Elastic** | Variable workloads | Pay for actual use | Default (recommended) |
| **Bursting** | Predictable baseline | Scales with size | Set `throughput_mode = "bursting"` |
| **Provisioned** | Guaranteed performance | Fixed cost | Set `throughput_mode = "provisioned"` + `provisioned_throughput_in_mibps` |

### 3. Storage Deployment Options

**Multi-AZ (Default - High Availability)**
```hcl
# availability_zone_name = null  # Default, creates Multi-AZ
```
- ✅ High availability across multiple zones
- ✅ Recommended for production
- ❌ Higher cost

**One Zone (Cost Optimized)**
```hcl
availability_zone_name = "us-east-1a"
```
- ✅ ~47% lower storage costs
- ✅ Good for non-critical workloads
- ❌ Single AZ availability

## Usage

### Prerequisites
- AWS credentials configured
- Terraform ~> 1.0 installed
- Understanding of your workload's access patterns

### Deploy

```bash
cd examples/complete

# Initialize Terraform
terraform init

# Review the comprehensive plan
terraform plan -var-file=test.tfvars

# Apply with all features
terraform apply -var-file=test.tfvars
```

### Monitor Lifecycle Transitions

After deployment, monitor storage class transitions:

```bash
# View file system details
aws efs describe-file-systems --file-system-id $(terraform output -raw file_system_id)

# Check lifecycle policy status
aws efs describe-lifecycle-configuration --file-system-id $(terraform output -raw file_system_id)
```

### View All Outputs

```bash
terraform output

# Example outputs:
# file_system_id = "fs-03cee4f754a47d6e5"
# file_system_dns_name = "fs-03cee4f754a47d6e5.efs.us-west-2.amazonaws.com"
# file_system_size_in_bytes = {...}
```

### Clean Up

```bash
terraform destroy -var-file=test.tfvars
```

## Customization Guide

### Adjust Lifecycle Policy Timings

Modify transition periods based on your data access patterns:

```hcl
lifecycle_policy = {
  transition_to_ia      = "AFTER_7_DAYS"   # More aggressive savings
  transition_to_archive = "AFTER_30_DAYS"  # Faster archival
}
```

### Enable Customer Managed Encryption

```hcl
kms_key_id = "arn:aws:kms:region:account:key/key-id"
```

### Use One Zone Storage

```hcl
availability_zone_name = "us-east-1a"  # Choose your preferred AZ
```

### Switch to Provisioned Throughput

```hcl
throughput_mode                 = "provisioned"
provisioned_throughput_in_mibps = 100  # MiB/s
```

## Best Practices Implemented

1. ✅ **Cost Optimization**: Lifecycle policies reduce storage costs by up to 95%
2. ✅ **Performance**: Elastic throughput automatically scales with workload
3. ✅ **Security**: Encryption at rest enabled by default
4. ✅ **Reliability**: Multi-AZ storage for high availability
5. ✅ **Observability**: Comprehensive outputs for monitoring
6. ✅ **Compliance**: Tagging strategy for cost allocation and governance

## Production Considerations

### After Deployment

1. **Create Mount Targets**: Deploy in private subnets across AZs
2. **Configure Security Groups**: Allow NFS traffic (port 2049) from compute resources
3. **Set Up Monitoring**: Enable CloudWatch metrics and alarms
4. **Configure Backups**: Use AWS Backup for point-in-time recovery
5. **Test Restore Procedures**: Validate backup and recovery processes

### Mount the File System

```bash
# On Amazon Linux 2
sudo yum install -y amazon-efs-utils
sudo mount -t efs -o tls fs-xxxxx:/ /mnt/efs

# On other Linux distributions
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 \
  fs-xxxxx.efs.region.amazonaws.com:/ /mnt/efs
```

## Resources Created

- **1 EFS File System** with:
  - ✅ Encryption enabled (AWS managed key, customer key supported)
  - ✅ Elastic throughput mode (automatic scaling)
  - ✅ Three-tier lifecycle policy (Standard → IA → Archive)
  - ✅ Protection configuration (replication controls)
  - ✅ Comprehensive tagging (cost allocation, compliance)
  - ✅ All outputs exposed (monitoring, integration)

## Comparison with Simple Example

| Feature | Simple Example | Complete Example |
|---------|----------------|------------------|
| Encryption | ✅ AWS managed | ✅ AWS or customer managed |
| Throughput Mode | Bursting | **Elastic** (recommended) |
| Lifecycle Policies | ❌ None | ✅ Full optimization |
| Storage Classes | Standard only | **Standard + IA + Archive** |
| Cost Optimization | None | **Up to 95% savings** |
| Production Ready | Development use | ✅ Production ready |

## Additional Resources

- [AWS EFS Documentation](https://docs.aws.amazon.com/efs/)
- [EFS Lifecycle Management](https://docs.aws.amazon.com/efs/latest/ug/lifecycle-management-efs.html)
- [EFS Performance Guide](https://docs.aws.amazon.com/efs/latest/ug/performance.html)
- [Module Source Code](../../main.tf)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.100 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_efs_complete"></a> [efs\_complete](#module\_efs\_complete) | ../../ | n/a |
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zone_name"></a> [availability\_zone\_name](#input\_availability\_zone\_name) | The AWS Availability Zone in which to create the file system. Used to create a file system that uses One Zone storage classes | `string` | `null` | no |
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | (Required) Environment where resource is going to be deployed. For example. dev, qa, uat | `string` | `"dev"` | no |
| <a name="input_creation_token"></a> [creation\_token](#input\_creation\_token) | Optional unique identifier for the EFS file system. If not provided, will use the generated or provided name value | `string` | `null` | no |
| <a name="input_encrypted"></a> [encrypted](#input\_encrypted) | If true, the disk will be encrypted | `bool` | `true` | no |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Number that represents the instance of the environment. | `number` | `0` | no |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Number that represents the instance of the resource. | `number` | `0` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN for the KMS encryption key. If set, the EFS file system will be encrypted at rest using this key | `string` | `null` | no |
| <a name="input_lifecycle_policy"></a> [lifecycle\_policy](#input\_lifecycle\_policy) | Lifecycle policy for the file system | <pre>object({<br/>    transition_to_ia                    = optional(string)<br/>    transition_to_primary_storage_class = optional(string)<br/>    transition_to_archive               = optional(string)<br/>  })</pre> | <pre>{<br/>  "transition_to_archive": "AFTER_90_DAYS",<br/>  "transition_to_ia": "AFTER_30_DAYS",<br/>  "transition_to_primary_storage_class": "AFTER_1_ACCESS"<br/>}</pre> | no |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | (Required) Name of the product family for which the resource is created.<br/>    Example: org\_name, department\_name. | `string` | `"launch"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | (Required) Name of the product service for which the resource is created.<br/>    For example, backend, frontend, middleware etc. | `string` | `"backend"` | no |
| <a name="input_name"></a> [name](#input\_name) | Optional name for the EFS file system. If not provided, a generated name from resource\_names module will be used | `string` | `null` | no |
| <a name="input_performance_mode"></a> [performance\_mode](#input\_performance\_mode) | The file system performance mode. Valid values: 'generalPurpose' (default, lower latency) or 'maxIO' (higher aggregate throughput) | `string` | `"generalPurpose"` | no |
| <a name="input_protection"></a> [protection](#input\_protection) | Protection configuration for the file system | <pre>object({<br/>    replication_overwrite = optional(string)<br/>  })</pre> | <pre>{<br/>  "replication_overwrite": "DISABLED"<br/>}</pre> | no |
| <a name="input_provisioned_throughput_in_mibps"></a> [provisioned\_throughput\_in\_mibps](#input\_provisioned\_throughput\_in\_mibps) | The throughput, measured in MiB/s, that you want to provision for the file system. Only applicable when throughput\_mode is set to 'provisioned' | `number` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | (Required) The location where the resource will be created. Must not have spaces<br/>    For example, us-east-1, us-west-2, eu-west-1, etc. | `string` | `"us-east-2"` | no |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names | <pre>map(object(<br/>    {<br/>      name       = string<br/>      max_length = optional(number, 60)<br/>    }<br/>  ))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the EFS file system | `map(string)` | <pre>{<br/>  "Application": "web-app",<br/>  "CostCenter": "engineering",<br/>  "Environment": "production",<br/>  "Example": "complete",<br/>  "ManagedBy": "Terraform"<br/>}</pre> | no |
| <a name="input_throughput_mode"></a> [throughput\_mode](#input\_throughput\_mode) | Throughput mode for the file system. Valid values: 'bursting', 'provisioned', or 'elastic' | `string` | `"elastic"` | no |

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

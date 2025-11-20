# Post-Deploy Functional Tests

This directory contains **full lifecycle tests** for the EFS file system module. These tests deploy infrastructure, validate it, and tear it down automatically.

## Purpose

These tests perform complete end-to-end validation:
1. ✅ **Setup**: Deploy Terraform examples to AWS
2. ✅ **Test**: Validate resources and outputs
3. ✅ **Teardown**: Destroy all created resources

## Test Scope

This test suite validates:
- EFS file system creation and configuration
- Encryption settings
- Performance and throughput modes
- Lifecycle policies (complete example)
- Resource tagging
- Terraform outputs accuracy
- AWS API consistency

## Running Tests

### ⚠️ Run from Repository Root

**Do NOT run tests from this directory.** Always execute from the repository root:

```bash
# Correct ✅
cd /workspace
go test -v ./tests/post_deploy_functional/...

# Incorrect ❌
cd /workspace/tests/post_deploy_functional
go test -v .
```

### Prerequisites

1. **AWS Credentials** with EFS permissions
2. **Go 1.24+** installed
3. **Unique creation tokens** in test.tfvars to avoid conflicts

### Run All Tests

```bash
# From repository root
cd /workspace
go test -v ./tests/post_deploy_functional/...
```

### Run Specific Example

The test framework automatically discovers and tests all examples in the `examples/` directory:
- `examples/simple/` - Basic configuration
- `examples/complete/` - Full-featured configuration

## Test Configuration

Tests use configuration files from each example:
- `examples/simple/test.tfvars`
- `examples/complete/test.tfvars`

To customize test parameters, edit the appropriate `test.tfvars` file.

## Test Flow

```
┌──────────────────────────────────────┐
│ 1. SETUP PHASE                       │
│    • cd examples/simple              │
│    • terraform init                  │
│    • terraform apply -var-file=...   │
└─────────────┬────────────────────────┘
              │
┌─────────────▼────────────────────────┐
│ 2. TEST PHASE                        │
│    • Retrieve outputs                │
│    • Query AWS API                   │
│    • Run assertions:                 │
│      - File system exists            │
│      - Encryption enabled            │
│      - Outputs match AWS             │
│      - Tags are correct              │
│      - Name is set                   │
└─────────────┬────────────────────────┘
              │
┌─────────────▼────────────────────────┐
│ 3. TEARDOWN PHASE                    │
│    • terraform destroy               │
│    • Verify cleanup                  │
└──────────────────────────────────────┘
```

## Environment Variables

Control test behavior:

```bash
# Skip teardown (leave resources for debugging)
export SKIP_teardown_test_simple=true
go test -v ./tests/post_deploy_functional/...

# Skip setup (use existing resources)
export SKIP_setup_test_simple=true
go test -v ./tests/post_deploy_functional/...
```

## Test Implementation

Test logic is implemented in `../testimpl/test_impl.go`:
- `TestComposableComplete()` - Main test function
- Individual assertion functions for each validation

## Expected Output

Successful test run:

```
=== RUN   TestModule
=== RUN   TestModule/TestFileSystemId
=== RUN   TestModule/TestFileSystemArn
=== RUN   TestModule/TestFileSystemDnsName
=== RUN   TestModule/TestFileSystemCreationToken
=== RUN   TestModule/TestFileSystemEncryption
=== RUN   TestModule/TestFileSystemName
=== RUN   TestModule/TestFileSystemThroughputMode
--- PASS: TestModule (45.23s)
    --- PASS: TestModule/TestFileSystemId (0.00s)
    --- PASS: TestModule/TestFileSystemArn (0.00s)
    --- PASS: TestModule/TestFileSystemDnsName (0.00s)
    --- PASS: TestModule/TestFileSystemCreationToken (0.00s)
    --- PASS: TestModule/TestFileSystemEncryption (0.00s)
    --- PASS: TestModule/TestFileSystemName (0.00s)
    --- PASS: TestModule/TestFileSystemThroughputMode (0.00s)
PASS
ok      github.com/launchbynttdata/tf-aws-module_primitive-efs_file_system/tests/post_deploy_functional    45.234s
```

## Cost Warning

⚠️ **These tests create real AWS resources** that incur costs:
- EFS file systems (charged per GB-month)
- Data transfer (if applicable)

Resources are automatically cleaned up after tests, but failures may leave orphaned resources. Always verify cleanup in the AWS Console.

## Troubleshooting

### Test Hangs During Apply
- EFS creation typically takes 10-30 seconds
- Tests complete naturally without timeout flags
- If hung, cancel with Ctrl+C and check AWS Console

### Resource Already Exists Error
- Change `creation_token` in test.tfvars to a unique value
- Clean up existing resources: `cd examples/simple && terraform destroy`

### Permission Denied
- Verify AWS credentials are configured
- Required IAM permissions:
  - `elasticfilesystem:CreateFileSystem`
  - `elasticfilesystem:DescribeFileSystems`
  - `elasticfilesystem:DeleteFileSystem`
  - `elasticfilesystem:PutLifecycleConfiguration`
  - `elasticfilesystem:TagResource`

### Resources Not Cleaned Up
- Manually destroy: `cd examples/simple && terraform destroy -var-file=test.tfvars`
- Check AWS Console for orphaned file systems
- Note the creation token for identification

## Related Files

- `main_test.go` - Test entry point
- `../testimpl/test_impl.go` - Test implementation and assertions
- `../../examples/simple/test.tfvars` - Simple example test configuration
- `../../examples/complete/test.tfvars` - Complete example test configuration

## Next Steps

After tests pass:
1. ✅ Review test output for any warnings
2. ✅ Verify resources were cleaned up in AWS Console
3. ✅ Update test.tfvars for different scenarios
4. ✅ Add additional test cases in `../testimpl/test_impl.go`

For more information, see the [main tests README](../README.md).

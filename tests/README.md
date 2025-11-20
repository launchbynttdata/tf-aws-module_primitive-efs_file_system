# Tests Directory

This directory contains the automated test suite for the `tf-aws-module_primitive-efs_file_system` module. Tests are implemented using [Terratest](https://terratest.gruntwork.io/) and the Launch Common Automation Framework (LCAF) testing library.

## Directory Structure

```
tests/
├── README.md                          # This file
├── post_deploy_functional/            # Full lifecycle tests (deploy, test, destroy)
│   ├── README.md
│   └── main_test.go
├── post_deploy_functional_readonly/   # Read-only tests (no deploy/destroy)
│   ├── README.md
│   └── main_test.go
└── testimpl/                          # Shared test implementation
    ├── README.md
    ├── test_impl.go                   # Test logic and assertions
    └── types.go                       # Test configuration types
```

## Test Types

### Post-Deploy Functional Tests
Located in `post_deploy_functional/`, these tests:
- ✅ Deploy the Terraform examples
- ✅ Validate resource creation and configuration
- ✅ Verify outputs match expected values
- ✅ Destroy resources after testing

### Post-Deploy Functional Read-Only Tests
Located in `post_deploy_functional_readonly/`, these tests:
- ✅ Assume resources are already deployed
- ✅ Run validation and assertions only
- ✅ Do not create or destroy resources
- ✅ Useful for CI/CD when resources persist between stages

### Test Implementation
Located in `testimpl/`, this package contains:
- Shared test logic and assertion functions
- AWS SDK integration for resource verification
- Reusable test utilities
- Configuration type definitions

## Running Tests

### ⚠️ Important: Run from Repository Root

**Do NOT run tests from this directory.** Always execute tests from the repository root:

```bash
# Correct - run from repository root
cd /workspace
go test -v ./tests/post_deploy_functional/...

# Incorrect - do not run from tests directory
cd /workspace/tests
go test -v ./post_deploy_functional/...  # ❌ Wrong
```

### Prerequisites

1. **AWS Credentials**: Configure AWS credentials with permissions to create/delete EFS resources
   ```bash
   export AWS_REGION=us-west-2
   export AWS_ACCESS_KEY_ID=your_access_key
   export AWS_SECRET_ACCESS_KEY=your_secret_key
   ```

2. **Go Installation**: Go 1.24 or later
   ```bash
   go version
   ```

3. **Dependencies**: Install Go modules
   ```bash
   cd /workspace
   go mod download
   ```

### Running All Tests

```bash
# From repository root
cd /workspace

# Run all post-deploy functional tests
go test -v ./tests/post_deploy_functional/...

# Run with timeout (recommended)
go test -v ./tests/post_deploy_functional/...

# Run with verbose output
go test -v -count=1 ./tests/post_deploy_functional/...
```

### Running Specific Test Suites

```bash
# Run only post_deploy_functional tests
go test -v ./tests/post_deploy_functional

# Run only post_deploy_functional_readonly tests
go test -v ./tests/post_deploy_functional_readonly

# Run specific test function
go test -v ./tests/post_deploy_functional -run TestModule
```

### Test Environment Variables

Control test behavior with environment variables:

```bash
# Skip teardown (leave resources for inspection)
export SKIP_teardown_test_simple=true
go test -v ./tests/post_deploy_functional/...

# Skip setup (use existing infrastructure)
export SKIP_setup_test_simple=true
go test -v ./tests/post_deploy_functional/...

# Disable test parallelization
export DISABLE_PARALLEL=true
go test -v ./tests/post_deploy_functional/...
```

## Test Coverage

The test suite validates:

### EFS File System Properties
- ✅ File system ID format and uniqueness
- ✅ ARN format and correctness
- ✅ DNS name format and reachability
- ✅ Creation token matches configuration
- ✅ Encryption is enabled as configured
- ✅ Name tag is set correctly

### AWS Resource Verification
- ✅ Resources exist in AWS (via SDK)
- ✅ Resource properties match Terraform outputs
- ✅ Throughput mode is configured correctly
- ✅ Performance mode matches expectations

### Output Validation
- ✅ All outputs are populated
- ✅ Output values match AWS API responses
- ✅ Outputs use correct formats

## Test Execution Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Setup Phase                                              │
│    • Initialize Terraform                                   │
│    • Read test.tfvars configuration                         │
│    • Run terraform apply                                    │
└────────────────────────────┬────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────┐
│ 2. Test Phase                                               │
│    • Retrieve Terraform outputs                             │
│    • Query AWS API for resource details                     │
│    • Run assertion tests:                                   │
│      - TestFileSystemId                                     │
│      - TestFileSystemArn                                    │
│      - TestFileSystemDnsName                                │
│      - TestFileSystemCreationToken                          │
│      - TestFileSystemEncryption                             │
│      - TestFileSystemName                                   │
│      - TestFileSystemThroughputMode                         │
└────────────────────────────┬────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────┐
│ 3. Teardown Phase                                           │
│    • Run terraform destroy                                  │
│    • Clean up test resources                                │
│    • Verify resources are deleted                           │
└─────────────────────────────────────────────────────────────┘
```

## Troubleshooting

### Common Issues

**Tests fail with "timeout"**
- EFS resources can take time to create/delete
- Tests run to completion naturally without timeout flags
- If a test hangs, cancel it manually (Ctrl+C)

**Tests fail with "permission denied"**
- Verify AWS credentials are configured
- Ensure IAM permissions include EFS actions:
  - `elasticfilesystem:CreateFileSystem`
  - `elasticfilesystem:DescribeFileSystems`
  - `elasticfilesystem:DeleteFileSystem`
  - `elasticfilesystem:PutLifecycleConfiguration`

**Tests fail with "resource already exists"**
- Change `creation_token` in test.tfvars to a unique value
- Clean up existing resources manually
- Check for orphaned resources in AWS Console

**Tests fail but resources remain**
- Set `SKIP_teardown_test_simple=true` to debug
- Manually destroy with: `cd examples/simple && terraform destroy`
- Check AWS Console for lingering resources

### Debug Mode

Enable detailed test output:

```bash
# Maximum verbosity
TF_LOG=DEBUG go test -v ./tests/post_deploy_functional/...

# Show Terraform output
go test -v ./tests/post_deploy_functional/... 2>&1 | tee test.log
```

## Adding New Tests

To add additional test coverage:

1. **Add test functions** to `testimpl/test_impl.go`
   ```go
   func testNewFeature(t *testing.T, awsFileSystem *types.FileSystemDescription) {
       // Your assertions here
   }
   ```

2. **Call from TestComposableComplete** in `testimpl/test_impl.go`
   ```go
   t.Run("TestNewFeature", func(t *testing.T) {
       testNewFeature(t, &awsFileSystem)
   })
   ```

3. **Run tests** to verify
   ```bash
   go test -v ./tests/post_deploy_functional/...
   ```

## Best Practices

1. ✅ Always run tests from repository root
2. ✅ Use unique `creation_token` values to avoid conflicts
3. ✅ Let tests run to completion naturally (no timeout flags)
4. ✅ Clean up resources after testing
5. ✅ Use environment variables to control test behavior
6. ✅ Review test output for failures and warnings
7. ✅ Verify resources are deleted after teardown

## Continuous Integration

These tests are designed to run in CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run Tests
  run: |
    cd /workspace
    go test -v ./tests/post_deploy_functional/...
  env:
    AWS_REGION: us-west-2
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## Related Documentation

- [Terratest Documentation](https://terratest.gruntwork.io/)
- [LCAF Testing Library](https://github.com/launchbynttdata/lcaf-component-terratest)
- [AWS EFS API Reference](https://docs.aws.amazon.com/efs/latest/ug/api-reference.html)
- [Root README](../README.md)

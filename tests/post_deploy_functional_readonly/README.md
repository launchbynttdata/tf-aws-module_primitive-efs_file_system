# Post-Deploy Functional Read-Only Tests

This directory contains **read-only validation tests** for the EFS file system module. These tests assume resources are already deployed and only perform validation without creating or destroying infrastructure.

## Purpose

These tests are designed for scenarios where:
- ✅ Infrastructure is pre-deployed and persistent
- ✅ Multiple test runs against the same resources
- ✅ CI/CD pipelines with separate deploy/test/destroy stages
- ✅ Manual verification without modifying infrastructure

## Key Difference from Standard Tests

| Feature | post_deploy_functional | post_deploy_functional_readonly |
|---------|------------------------|--------------------------------|
| Deploy resources | ✅ Yes | ❌ No |
| Run validations | ✅ Yes | ✅ Yes |
| Destroy resources | ✅ Yes | ❌ No |
| Use case | Full lifecycle testing | Validation only |

## When to Use

Use these tests when:
1. **Resources already exist** and should not be modified
2. **CI/CD has separate stages** for deploy, test, and destroy
3. **Testing production** or long-lived environments
4. **Debugging** infrastructure without recreating it
5. **Cost optimization** - avoid repeated create/destroy cycles

## Running Tests

### ⚠️ Run from Repository Root

**Do NOT run tests from this directory.** Always execute from the repository root:

```bash
# Correct ✅
cd /workspace
go test -v ./tests/post_deploy_functional_readonly/...

# Incorrect ❌
cd /workspace/tests/post_deploy_functional_readonly
go test -v .
```

### Prerequisites

1. **Pre-deployed EFS infrastructure**
   ```bash
   cd /workspace/examples/simple
   terraform init
   terraform apply -var-file=test.tfvars
   ```

2. **AWS credentials** with read permissions

3. **Terraform state** must exist in the example directory

### Run Read-Only Tests

```bash
# From repository root
cd /workspace

# Run against pre-deployed infrastructure
go test -v ./tests/post_deploy_functional_readonly/...
```

## Test Flow

```
┌──────────────────────────────────────┐
│ PREREQUISITES (Manual)               │
│  • Resources already deployed        │
│  • Terraform state exists            │
│  • AWS credentials configured        │
└─────────────┬────────────────────────┘
              │
┌─────────────▼────────────────────────┐
│ 1. READ PHASE                        │
│    • Read existing Terraform state   │
│    • Retrieve outputs                │
│    • No terraform apply/destroy      │
└─────────────┬────────────────────────┘
              │
┌─────────────▼────────────────────────┐
│ 2. TEST PHASE                        │
│    • Query AWS API                   │
│    • Run all validation tests        │
│    • Verify resource properties      │
│    • Assert outputs are correct      │
└─────────────┬────────────────────────┘
              │
┌─────────────▼────────────────────────┐
│ 3. NO TEARDOWN                       │
│    • Resources remain deployed       │
│    • State unchanged                 │
│    • Manual cleanup required         │
└──────────────────────────────────────┘
```

## Usage Scenarios

### Scenario 1: CI/CD Pipeline with Stages

```yaml
# GitHub Actions example
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy Infrastructure
        run: |
          cd examples/simple
          terraform init
          terraform apply -var-file=test.tfvars -auto-approve

  test:
    needs: deploy
    runs-on: ubuntu-latest
    steps:
      - name: Run Read-Only Tests
        run: go test -v ./tests/post_deploy_functional_readonly/...

  destroy:
    needs: test
    if: always()
    runs-on: ubuntu-latest
    steps:
      - name: Destroy Infrastructure
        run: |
          cd examples/simple
          terraform destroy -var-file=test.tfvars -auto-approve
```

### Scenario 2: Manual Testing

```bash
# 1. Deploy infrastructure once
cd /workspace/examples/simple
terraform init
terraform apply -var-file=test.tfvars

# 2. Run tests multiple times (no redeploy)
cd /workspace
go test -v ./tests/post_deploy_functional_readonly/...
go test -v ./tests/post_deploy_functional_readonly/...
go test -v ./tests/post_deploy_functional_readonly/...

# 3. Clean up when done
cd /workspace/examples/simple
terraform destroy -var-file=test.tfvars
```

### Scenario 3: Production Validation

```bash
# Test against existing production EFS
# (Assumes Terraform state is accessible)
cd /workspace
export ENVIRONMENT=production
go test -v ./tests/post_deploy_functional_readonly/...
```

## Environment Variables

Control test behavior:

```bash
# Force skip of setup phase (already default for readonly)
export SKIP_setup_test_simple=true

# Force skip of teardown phase (already default for readonly)
export SKIP_teardown_test_simple=true

# Run tests
go test -v ./tests/post_deploy_functional_readonly/...
```

## Test Implementation

Test logic is shared with full lifecycle tests:
- Main test file: `main_test.go`
- Shared implementation: `../testimpl/test_impl.go`
- Same validation tests as `post_deploy_functional`

The only difference is the test execution strategy - no setup or teardown phases.

## Expected Output

Successful test run:

```
=== RUN   TestLambdaLayerModule
=== RUN   TestLambdaLayerModule/TestFileSystemId
=== RUN   TestLambdaLayerModule/TestFileSystemArn
=== RUN   TestLambdaLayerModule/TestFileSystemDnsName
=== RUN   TestLambdaLayerModule/TestFileSystemCreationToken
=== RUN   TestLambdaLayerModule/TestFileSystemEncryption
=== RUN   TestLambdaLayerModule/TestFileSystemName
=== RUN   TestLambdaLayerModule/TestFileSystemThroughputMode
--- PASS: TestLambdaLayerModule (2.45s)
    --- PASS: TestLambdaLayerModule/TestFileSystemId (0.00s)
    --- PASS: TestLambdaLayerModule/TestFileSystemArn (0.00s)
    --- PASS: TestLambdaLayerModule/TestFileSystemDnsName (0.00s)
    --- PASS: TestLambdaLayerModule/TestFileSystemCreationToken (0.00s)
    --- PASS: TestLambdaLayerModule/TestFileSystemEncryption (0.00s)
    --- PASS: TestLambdaLayerModule/TestFileSystemName (0.00s)
    --- PASS: TestLambdaLayerModule/TestFileSystemThroughputMode (0.00s)
PASS
ok      github.com/launchbynttdata/tf-aws-module_primitive-efs_file_system/tests/post_deploy_functional_readonly    2.456s
```

Note: Tests run much faster (~2s vs ~45s) since no deployment occurs.

## Advantages

1. ✅ **Faster execution** - No deployment or teardown overhead
2. ✅ **Cost effective** - Reuse existing infrastructure for multiple test runs
3. ✅ **Non-destructive** - Safe to run against persistent environments
4. ✅ **CI/CD friendly** - Fits well into staged pipelines
5. ✅ **Debugging** - Test validation logic without recreating resources

## Limitations

1. ❌ **Requires pre-deployment** - Infrastructure must exist before running
2. ❌ **No cleanup** - Resources must be manually destroyed
3. ❌ **State dependency** - Requires access to Terraform state
4. ❌ **Not fully isolated** - Tests share the same infrastructure

## Troubleshooting

### Test Fails: "No Terraform State"
- Ensure resources are deployed: `cd examples/simple && terraform apply -var-file=test.tfvars`
- Verify Terraform state file exists: `ls examples/simple/terraform.tfstate`

### Test Fails: "File System Not Found"
- Resources may have been destroyed
- Redeploy: `cd examples/simple && terraform apply -var-file=test.tfvars`

### Test Fails: "Output Not Found"
- Terraform state may be out of sync
- Refresh state: `cd examples/simple && terraform refresh -var-file=test.tfvars`

### Wrong Resources Tested
- Ensure you're in the correct example directory
- Verify Terraform state points to the expected resources
- Check creation token in outputs matches expected value

## Cleanup

After testing, manually destroy resources:

```bash
# Destroy simple example
cd /workspace/examples/simple
terraform destroy -var-file=test.tfvars

# Destroy complete example
cd /workspace/examples/complete
terraform destroy -var-file=test.tfvars

# Verify cleanup in AWS Console
aws efs describe-file-systems
```

## Related Files

- `main_test.go` - Test entry point (readonly mode)
- `../post_deploy_functional/main_test.go` - Full lifecycle version
- `../testimpl/test_impl.go` - Shared test implementation
- `../../examples/simple/` - Example to test against

## Next Steps

1. ✅ Deploy infrastructure before running these tests
2. ✅ Run tests to validate existing resources
3. ✅ Use in CI/CD pipelines with separate stages
4. ✅ Remember to clean up resources when done

For more information, see the [main tests README](../README.md).

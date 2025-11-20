# Test Implementation Package

This package (`testimpl`) contains the **shared test implementation logic** for the EFS file system module tests. It provides reusable test functions, AWS SDK integrations, and assertion utilities used by both full lifecycle and read-only test suites.

## Purpose

This package serves as the central location for:
- ✅ Test logic and validation functions
- ✅ AWS SDK client configuration
- ✅ Resource verification using AWS APIs
- ✅ Reusable assertion utilities
- ✅ Test configuration type definitions

## Package Contents

### `test_impl.go`
Main test implementation file containing:

#### Core Test Function
- `TestComposableComplete()` - Main test orchestration function
  - Retrieves Terraform outputs
  - Queries AWS EFS API for actual resource details
  - Executes all validation test cases
  - Coordinates test execution flow

#### Validation Functions
Individual test functions for specific validations:
- `testFileSystemId()` - Validates EFS file system ID format and correctness
- `testFileSystemArn()` - Validates ARN format and matches AWS
- `testFileSystemDnsName()` - Validates DNS name format and content
- `testFileSystemCreationToken()` - Validates creation token matches
- `testFileSystemEncryption()` - Validates encryption is enabled
- `testFileSystemName()` - Validates Name tag is set correctly
- `testFileSystemThroughputMode()` - Validates throughput mode configuration

#### AWS Client Functions
Utility functions for AWS SDK integration:
- `GetAWSEFSClient()` - Creates authenticated EFS client
- `GetAWSConfig()` - Loads AWS configuration from environment

### `types.go`
Type definitions for test configuration:
- `ThisTFModuleConfig` - Module-specific test configuration structure
- Extends generic LCAF test configuration types

## Architecture

```
┌────────────────────────────────────────────────────┐
│ Test Entry Point                                   │
│ (post_deploy_functional/main_test.go)             │
└──────────────────┬─────────────────────────────────┘
                   │ calls
┌──────────────────▼─────────────────────────────────┐
│ testimpl.TestComposableComplete()                  │
│                                                    │
│ 1. Retrieve Terraform outputs                     │
│ 2. Query AWS EFS API                              │
│ 3. Execute validation tests                       │
└──────────────────┬─────────────────────────────────┘
                   │ calls
┌──────────────────▼─────────────────────────────────┐
│ Individual Test Functions                          │
│                                                    │
│ • testFileSystemId()                              │
│ • testFileSystemArn()                             │
│ • testFileSystemDnsName()                         │
│ • testFileSystemCreationToken()                   │
│ • testFileSystemEncryption()                      │
│ • testFileSystemName()                            │
│ • testFileSystemThroughputMode()                  │
└────────────────────────────────────────────────────┘
```

## How Tests Work

### 1. Terraform Output Retrieval
```go
fileSystemId := terraform.Output(t, ctx.TerratestTerraformOptions(), "file_system_id")
```
- Reads outputs from Terraform state
- Used as expected values for validation

### 2. AWS API Query
```go
fileSystem, err := efsClient.DescribeFileSystems(context.TODO(), &efs.DescribeFileSystemsInput{
    FileSystemId: aws.String(fileSystemId),
})
```
- Queries actual AWS resources using SDK
- Retrieves real-world resource state

### 3. Assertion and Validation
```go
assert.Equal(t, *awsFileSystem.FileSystemId, fileSystemId, "File system ID should match")
assert.True(t, *awsFileSystem.Encrypted, "File system should be encrypted")
```
- Compares Terraform outputs with AWS reality
- Validates resource configuration

## Not Intended for Direct Execution

⚠️ **This package is not meant to be run directly.** It contains shared code used by test suites in:
- `../post_deploy_functional/`
- `../post_deploy_functional_readonly/`

To run tests, use the test suite directories from the repository root:

```bash
# Correct ✅
cd /workspace
go test -v ./tests/post_deploy_functional/...

# Incorrect ❌
cd /workspace/tests/testimpl
go test -v .  # This won't work - no test files with main() here
```

## Adding New Test Functions

To add additional validation tests:

### Step 1: Add Test Function

Add a new test function in `test_impl.go`:

```go
func testNewFeature(t *testing.T, awsFileSystem *types.FileSystemDescription) {
    // Your test logic here
    assert.NotNil(t, awsFileSystem.NewField, "New field should be set")
    assert.Equal(t, expectedValue, *awsFileSystem.NewField, "New field should match expected value")
}
```

### Step 2: Add Test Case

Call the new test function from `TestComposableComplete()`:

```go
func TestComposableComplete(t *testing.T, ctx testTypes.TestContext) {
    // ... existing code ...

    t.Run("TestNewFeature", func(t *testing.T) {
        testNewFeature(t, &awsFileSystem)
    })
}
```

### Step 3: Run Tests

```bash
cd /workspace
go test -v ./tests/post_deploy_functional/...
```

## Dependencies

This package depends on:

### Testing Frameworks
- `testing` - Go standard library testing
- `github.com/stretchr/testify` - Enhanced assertions
- `github.com/gruntwork-io/terratest` - Terraform testing utilities
- `github.com/launchbynttdata/lcaf-component-terratest` - LCAF test framework

### AWS SDK
- `github.com/aws/aws-sdk-go-v2/aws` - AWS SDK core
- `github.com/aws/aws-sdk-go-v2/config` - AWS configuration
- `github.com/aws/aws-sdk-go-v2/service/efs` - EFS service client
- `github.com/aws/aws-sdk-go-v2/service/efs/types` - EFS types

## Test Function Patterns

### Pattern 1: Value Comparison
```go
func testExample(t *testing.T, awsFileSystem *types.FileSystemDescription, expectedValue string) {
    assert.Equal(t, expectedValue, *awsFileSystem.Field, "Field should match expected value")
}
```

### Pattern 2: Format Validation
```go
func testExample(t *testing.T, value string) {
    matched, _ := regexp.MatchString(`^pattern$`, value)
    assert.True(t, matched, "Value should match expected pattern")
}
```

### Pattern 3: Existence Check
```go
func testExample(t *testing.T, awsFileSystem *types.FileSystemDescription) {
    assert.NotNil(t, awsFileSystem.Field, "Field should not be nil")
    assert.NotEmpty(t, *awsFileSystem.Field, "Field should not be empty")
}
```

### Pattern 4: Boolean Assertion
```go
func testExample(t *testing.T, awsFileSystem *types.FileSystemDescription) {
    assert.NotNil(t, awsFileSystem.BoolField, "Bool field should not be nil")
    assert.True(t, *awsFileSystem.BoolField, "Bool field should be true")
}
```

## Assertion Library

Using `testify/assert`:

```go
// Equality
assert.Equal(t, expected, actual, "message")

// Truthiness
assert.True(t, condition, "message")
assert.False(t, condition, "message")

// Nil checks
assert.Nil(t, value, "message")
assert.NotNil(t, value, "message")

// Empty checks
assert.Empty(t, value, "message")
assert.NotEmpty(t, value, "message")

// Contains
assert.Contains(t, haystack, needle, "message")

// Error handling
assert.NoError(t, err, "message")
assert.Error(t, err, "message")
```

## Best Practices

1. ✅ **Descriptive test names** - Use clear, specific names for test functions
2. ✅ **Meaningful messages** - Provide helpful assertion messages
3. ✅ **Nil checks** - Always check for nil before dereferencing pointers
4. ✅ **Error handling** - Use `require.NoError()` for critical operations
5. ✅ **Granular tests** - One test function per validation concern
6. ✅ **Reusable utilities** - Extract common logic to helper functions

## Debugging Tests

### Enable Verbose Output
```bash
go test -v ./tests/post_deploy_functional/...
```

### Run Single Test Case
```bash
go test -v ./tests/post_deploy_functional/... -run TestModule/TestFileSystemId
```

### Print Variable Values
```go
t.Logf("File System ID: %s", fileSystemId)
t.Logf("AWS Response: %+v", awsFileSystem)
```

## Related Files

- `../post_deploy_functional/main_test.go` - Full lifecycle test entry
- `../post_deploy_functional_readonly/main_test.go` - Read-only test entry
- `../../main.tf` - Module implementation being tested
- `../../examples/simple/test.tfvars` - Test configuration

## Contributing

When adding new features to the EFS module:

1. ✅ Add corresponding test functions in `test_impl.go`
2. ✅ Update test cases in `TestComposableComplete()`
3. ✅ Run tests to verify: `go test -v ./tests/post_deploy_functional/...`
4. ✅ Document new test functions in this README

## Next Steps

For actual test execution:
- See [post_deploy_functional README](../post_deploy_functional/README.md)
- See [post_deploy_functional_readonly README](../post_deploy_functional_readonly/README.md)
- See [main tests README](../README.md)

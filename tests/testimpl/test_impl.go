package testimpl

import (
	"context"
	"regexp"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/efs"
	"github.com/aws/aws-sdk-go-v2/service/efs/types"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testTypes "github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestComposableComplete(t *testing.T, ctx testTypes.TestContext) {
	// Get AWS EFS client
	efsClient := GetAWSEFSClient(t)

	// Get outputs from Terraform
	fileSystemId := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "file_system_id")
	fileSystemArn := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "file_system_arn")
	fileSystemDnsName := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "file_system_dns_name")
	fileSystemCreationToken := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "file_system_creation_token")
	fileSystemName := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "file_system_name")

	// Get the actual file system from AWS
	fileSystem, err := efsClient.DescribeFileSystems(context.TODO(), &efs.DescribeFileSystemsInput{
		FileSystemId: aws.String(fileSystemId),
	})
	require.NoError(t, err, "Failed to describe EFS file system")
	require.NotEmpty(t, fileSystem.FileSystems, "No file systems returned from AWS")

	awsFileSystem := fileSystem.FileSystems[0]

	t.Run("TestFileSystemId", func(t *testing.T) {
		testFileSystemId(t, &awsFileSystem, fileSystemId)
	})

	t.Run("TestFileSystemArn", func(t *testing.T) {
		testFileSystemArn(t, &awsFileSystem, fileSystemArn)
	})

	t.Run("TestFileSystemDnsName", func(t *testing.T) {
		testFileSystemDnsName(t, fileSystemId, fileSystemDnsName)
	})

	t.Run("TestFileSystemCreationToken", func(t *testing.T) {
		testFileSystemCreationToken(t, &awsFileSystem, fileSystemCreationToken)
	})

	t.Run("TestFileSystemEncryption", func(t *testing.T) {
		testFileSystemEncryption(t, &awsFileSystem)
	})

	t.Run("TestFileSystemName", func(t *testing.T) {
		testFileSystemName(t, &awsFileSystem, fileSystemName)
	})

	t.Run("TestFileSystemThroughputMode", func(t *testing.T) {
		testFileSystemThroughputMode(t, &awsFileSystem)
	})
}

func testFileSystemId(t *testing.T, awsFileSystem *types.FileSystemDescription, fileSystemId string) {
	assert.Equal(t, *awsFileSystem.FileSystemId, fileSystemId, "File system ID from Terraform should match AWS")
	assert.NotEmpty(t, fileSystemId, "File system ID should not be empty")

	// Verify it's a valid EFS ID format
	matched, _ := regexp.MatchString(`^fs-[a-f0-9]+$`, fileSystemId)
	assert.True(t, matched, "File system ID should match format 'fs-xxxxxxxxx'")
}

func testFileSystemArn(t *testing.T, awsFileSystem *types.FileSystemDescription, fileSystemArn string) {
	assert.Equal(t, *awsFileSystem.FileSystemArn, fileSystemArn, "File system ARN from Terraform should match AWS")
	assert.NotEmpty(t, fileSystemArn, "File system ARN should not be empty")

	// Verify it's a valid ARN format
	matched, err := regexp.MatchString(`^arn:aws:elasticfilesystem:`, fileSystemArn)
	require.NoError(t, err, "Regex match for ARN failed")
	assert.True(t, matched, "ARN should start with 'arn:aws:elasticfilesystem:'")
}

func testFileSystemDnsName(t *testing.T, fileSystemId string, fileSystemDnsName string) {
	assert.NotEmpty(t, fileSystemDnsName, "DNS name should not be empty")
	assert.Contains(t, fileSystemDnsName, fileSystemId, "DNS name should contain the file system ID")
	assert.Contains(t, fileSystemDnsName, ".efs.", "DNS name should contain '.efs.'")
	assert.Contains(t, fileSystemDnsName, ".amazonaws.com", "DNS name should end with '.amazonaws.com'")
}

func testFileSystemCreationToken(t *testing.T, awsFileSystem *types.FileSystemDescription, fileSystemCreationToken string) {
	assert.Equal(t, *awsFileSystem.CreationToken, fileSystemCreationToken, "Creation token from Terraform should match AWS")
	assert.NotEmpty(t, fileSystemCreationToken, "Creation token should not be empty")
}

func testFileSystemEncryption(t *testing.T, awsFileSystem *types.FileSystemDescription) {
	assert.NotNil(t, awsFileSystem.Encrypted, "Encrypted field should not be nil")
	assert.True(t, *awsFileSystem.Encrypted, "File system should be encrypted")
}

func testFileSystemName(t *testing.T, awsFileSystem *types.FileSystemDescription, fileSystemName string) {
	assert.NotEmpty(t, fileSystemName, "File system name should not be empty")

	// Verify the Name tag exists in AWS
	if awsFileSystem.Name != nil {
		assert.Equal(t, *awsFileSystem.Name, fileSystemName, "File system name from Terraform should match AWS Name tag")
	}
}

func testFileSystemThroughputMode(t *testing.T, awsFileSystem *types.FileSystemDescription) {
	assert.NotNil(t, awsFileSystem.ThroughputMode, "Throughput mode should be set")
	// Valid values are bursting, provisioned, or elastic
	validModes := []string{"bursting", "provisioned", "elastic"}
	assert.Contains(t, validModes, string(awsFileSystem.ThroughputMode), "Throughput mode should be valid")
}

func GetAWSEFSClient(t *testing.T) *efs.Client {
	awsEFSClient := efs.NewFromConfig(GetAWSConfig(t))
	return awsEFSClient
}

func GetAWSConfig(t *testing.T) (cfg aws.Config) {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	require.NoErrorf(t, err, "unable to load SDK config, %v", err)
	return cfg
}

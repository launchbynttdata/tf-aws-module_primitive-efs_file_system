# GitHub Copilot Instructions

## File Editing Rules

- **NEVER remove license headers** from files when making edits
- Always preserve the Apache 2.0 license header at the top of all source files (`.tf`, `.go`, `.sh`, etc.)
- When editing files, include the full license header in replacements if modifying code near the top of files

## Terminal Command Rules

- **DO NOT use timeout flags** with terminal commands (e.g., avoid `-timeout` with go test)
- Let commands run to completion naturally
- If a command needs to be stopped, the user will cancel it manually
- For long-running tests, rely on the default behavior rather than imposing artificial time limits

## Terraform Best Practices

- Follow the module structure defined in the repository
- Maintain consistency with existing patterns
- Use dynamic blocks appropriately for optional nested configurations
- Always validate configurations with `terraform validate` before planning or applying

## Testing Guidelines

- Write comprehensive tests that verify actual AWS resource creation
- Use the AWS SDK to verify resource properties match Terraform outputs
- Test both required and optional parameters
- Include validation for resource naming, encryption, and other critical settings

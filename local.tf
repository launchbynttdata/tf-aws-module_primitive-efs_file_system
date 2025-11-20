locals {
  tags = merge(
    {
      "ManagedBy" = "Terraform"
    },
    var.name != null ? { "Name" = var.name } : {},
    var.tags,
  )
}

locals {
  tags = merge(
    {
      "ManagedBy" = "Terraform"
      "Name"      = var.name
    },
    var.tags,
  )
}

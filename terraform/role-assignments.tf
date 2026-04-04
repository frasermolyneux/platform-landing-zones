resource "azurerm_role_assignment" "breakglass_owner" {
  for_each = local.all_subscription_ids

  scope                = "/subscriptions/${each.value}"
  role_definition_name = "Owner"
  principal_id         = var.breakglass_principal_id
  principal_type       = "User"

  lifecycle {
    prevent_destroy = true
  }
}

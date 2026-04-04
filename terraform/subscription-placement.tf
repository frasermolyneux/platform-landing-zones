resource "azurerm_management_group_subscription_association" "this" {
  for_each = local.subscription_placements

  management_group_id = each.value
  subscription_id     = "/subscriptions/${each.key}"
}

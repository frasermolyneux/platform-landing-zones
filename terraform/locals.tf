locals {
  all_subscription_ids = toset(concat(
    var.management_subscriptions,
    var.connectivity_subscriptions,
    var.identity_subscriptions,
    var.landing_zone_subscriptions,
    var.sandbox_subscriptions,
    var.decommissioned_subscriptions,
  ))

  subscription_placements = merge(
    { for id in var.management_subscriptions : id => azurerm_management_group.platform_management.id },
    { for id in var.connectivity_subscriptions : id => azurerm_management_group.platform_connectivity.id },
    { for id in var.identity_subscriptions : id => azurerm_management_group.platform_identity.id },
    { for id in var.landing_zone_subscriptions : id => azurerm_management_group.landing_zones.id },
    { for id in var.sandbox_subscriptions : id => azurerm_management_group.sandbox.id },
    { for id in var.decommissioned_subscriptions : id => azurerm_management_group.decommissioned.id },
  )
}

# Level 1 - Root management group
resource "azurerm_management_group" "root" {
  name         = var.management_group_prefix
  display_name = "Azure Landing Zones"
}

# Level 2 - Platform
resource "azurerm_management_group" "platform" {
  name                       = "${var.management_group_prefix}-platform"
  display_name               = "Platform"
  parent_management_group_id = azurerm_management_group.root.id
}

# Level 2 - Landing Zones
resource "azurerm_management_group" "landing_zones" {
  name                       = "${var.management_group_prefix}-landingzones"
  display_name               = "Landing Zones"
  parent_management_group_id = azurerm_management_group.root.id
}

# Level 2 - Sandbox
resource "azurerm_management_group" "sandbox" {
  name                       = "${var.management_group_prefix}-sandbox"
  display_name               = "Sandbox"
  parent_management_group_id = azurerm_management_group.root.id
}

# Level 2 - Decommissioned
resource "azurerm_management_group" "decommissioned" {
  name                       = "${var.management_group_prefix}-decommissioned"
  display_name               = "Decommissioned"
  parent_management_group_id = azurerm_management_group.root.id
}

# Level 3 - Platform > Management
resource "azurerm_management_group" "platform_management" {
  name                       = "${var.management_group_prefix}-platform-management"
  display_name               = "Management"
  parent_management_group_id = azurerm_management_group.platform.id
}

# Level 3 - Platform > Connectivity
resource "azurerm_management_group" "platform_connectivity" {
  name                       = "${var.management_group_prefix}-platform-connectivity"
  display_name               = "Connectivity"
  parent_management_group_id = azurerm_management_group.platform.id
}

# Level 3 - Platform > Identity
resource "azurerm_management_group" "platform_identity" {
  name                       = "${var.management_group_prefix}-platform-identity"
  display_name               = "Identity"
  parent_management_group_id = azurerm_management_group.platform.id
}

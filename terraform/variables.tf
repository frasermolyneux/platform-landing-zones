variable "environment" {
  default = "prd"
}

variable "location" {
  default = "uksouth"
}

variable "subscription_id" {
  type        = string
  description = "The subscription ID used for provider context (management subscription)."
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "management_group_prefix" {
  type        = string
  default     = "alz"
  description = "The prefix used for all management group names and IDs."
}

variable "management_subscriptions" {
  type        = list(string)
  default     = []
  description = "Subscription IDs to place under the Platform > Management management group."
}

variable "connectivity_subscriptions" {
  type        = list(string)
  default     = []
  description = "Subscription IDs to place under the Platform > Connectivity management group."
}

variable "identity_subscriptions" {
  type        = list(string)
  default     = []
  description = "Subscription IDs to place under the Platform > Identity management group."
}

variable "landing_zone_subscriptions" {
  type        = list(string)
  default     = []
  description = "Subscription IDs to place under the Landing Zones management group."
}

variable "sandbox_subscriptions" {
  type        = list(string)
  default     = []
  description = "Subscription IDs to place under the Sandbox management group."
}

variable "decommissioned_subscriptions" {
  type        = list(string)
  default     = []
  description = "Subscription IDs to place under the Decommissioned management group."
}

variable "breakglass_principal_id" {
  type        = string
  description = "Object ID of the break-glass user account to assign Owner role across all subscriptions."
}

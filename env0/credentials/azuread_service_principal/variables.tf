### VARIABLES

variable "azure_cost_sp_name" {
  type        = string
  default     = "env0-cost-role"
  description = "name used for both env0 and Azure"
}

variable "azure_sp_name" {
  type        = string
  default     = "env0-deployer-role"
  description = "name used for both env0 and Azure"
}

# variable "subscription_id" {
#   type = string
#   description = "azure subscription_id"
# }
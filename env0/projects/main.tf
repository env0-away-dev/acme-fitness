locals {
  template_project_pair = {
    for k, v in setproduct(toset(var.team_environments), toset(var.default_templates)) :
    join(",", k) => {
      environment = "${v[0]}",
      template    = "${v[1]}"
    }
  }

  cred_env_pair = merge([
    for cred, env_list in var.aws_credentials : [
      for env in env_list :
        { key = env }
    ]
  ])
}

output "template_project" {
  value = setproduct(toset(var.team_environments), toset(var.default_templates))
}

output "team_name" {
  value = var.team_name
}

output "team_environments" {
  value = var.team_environments
}

resource "env0_project" "team_project" {
  name        = var.team_name
  description = var.description
}

resource "env0_project" "environment_projects" {
  for_each = toset(var.team_environments)

  name              = each.value
  description       = "${each.value} environment for ${var.team_name} project"
  parent_project_id = env0_project.team_project.id
}

resource "env0_project_policy" "environment_policies" {
  for_each = toset(var.team_environments)

  project_id                    = env0_project.environment_projects[each.key].id
  disable_destroy_environments  = var.policies[each.key].disable_destroy_environments
  number_of_environments        = var.policies[each.key].number_of_environments
  number_of_environments_total  = var.policies[each.key].number_of_environments_total
  requires_approval_default     = var.policies[each.key].requires_approval_default
  default_ttl                   = var.policies[each.key].default_ttl
  max_ttl                       = var.policies[each.key].max_ttl
  include_cost_estimation       = var.policies[each.key].include_cost_estimation
  skip_apply_when_plan_is_empty = var.policies[each.key].skip_apply_when_plan_is_empty
  skip_redundant_deployments    = var.policies[each.key].skip_redundant_deployments
  continuous_deployment_default = var.policies[each.key].continuous_deployment_default
  run_pull_request_plan_default = var.policies[each.key].run_pull_request_plan_default
  force_remote_backend          = var.policies[each.key].force_remote_backend
  drift_detection_cron          = var.policies[each.key].drift_detection_cron
}

data "env0_template" "defaults" {
  for_each = toset(var.default_templates)

  name = each.key
}

resource "env0_template_project_assignment" "assignment" {
  for_each = local.template_project_pair

  template_id = data.env0_template.defaults[each.value.template].id
  project_id  = env0_project.environment_projects[each.value.environment].id
}

data "env0_aws_credentials" "name" {
  for_each = var.aws_credentials
  
  name = each.key
}

# resource "env0_cloud_credentials_project_assignment" "example" {
#   for_each = local.cred_env_pair

#   credential_id = data.env0_aws_credentials.name[each.key].id
#   project_id    = env0_project.environment_projects[each.value].id
# }

output "env0_cred_flatten" {
  value = local.cred_env_pair
}
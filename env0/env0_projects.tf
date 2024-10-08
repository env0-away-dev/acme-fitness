resource "env0_template" "projects" {
  name             = "Team Projects"
  type             = "opentofu"
  description      = "Project Factory for onboarding new teams"
  opentofu_version = "latest"
  repository       = data.env0_template.this.repository
  path             = "env0/projects"

  # vcs
  github_installation_id = var.vcs == "github" ? data.env0_template.this.github_installation_id : null
  bitbucket_client_key   = var.vcs == "bitbucket" ? data.env0_template.this.bitbucket_client_key : null
  # gitlab_project_id    = data.env0_template.this.gitlab_project_id
  is_azure_devops = var.vcs == "azure" ? data.env0_template.this.is_azure_devops : null
  token_id        = var.vcs == "gitlab" ? data.env0_template.this.token_id : null
}

resource "env0_template_project_assignment" "projects" {
  template_id = env0_template.projects.id
  project_id  = data.env0_environment.this.project_id
}

resource "env0_configuration_variable" "team_name" {
  template_id = env0_template.projects.id
  name        = "team_name"
  description = "main project name for team"
  is_required = true
  regex       = "[a-zA-Z0-9-_]*"
  type        = "terraform"
}

resource "env0_configuration_variable" "description" {
  template_id = env0_template.projects.id
  name        = "description"
  is_required = false
  type        = "terraform"
  description = "project description"
}

resource "env0_configuration_variable" "team_environments" {
  template_id = env0_template.projects.id
  name        = "team_environments"
  description = "staging environments for team"
  format      = "JSON"
  type        = "terraform"
  value       = "[\"Dev\", \"Stage\", \"Prod\"]"
}

# default credential configuration 
resource "env0_configuration_variable" "aws_credentials" {
  template_id = env0_template.projects.id
  name        = "aws_credentials"
  description = "aws_credentials for project"
  format      = "JSON"
  type        = "terraform"
  value       = jsonencode({
    (module.assume-role.deployer_arn) = ["Dev", "Stage", "Prod"]
  })
  
}

resource "env0_configuration_variable" "default_templates" {
  template_id = env0_template.projects.id
  name        = "default_templates"
  description = "templates to auto attach to projects"
  format      = "JSON"
  type        = "terraform"
  value       = "[\"vpc\", \"ec2\", \"s3\", \"random_pet\"]"
}

resource "env0_configuration_variable" "environment_policies" {
  template_id = env0_template.projects.id
  name        = "policies"
  description = "the default project policies for each staging environment"
  format      = "HCL"
  type        = "terraform"
  value       = <<-EOT
  { 
    Dev = {
      disable_destroy_environments  = false
      number_of_environments        = 3
      number_of_environments_total  = 10
      requires_approval_default     = false
      default_ttl                   = "12-h"
      max_ttl                       = "1-w"
      include_cost_estimation       = true
      skip_apply_when_plan_is_empty = true
      skip_redundant_deployments    = true
      continuous_deployment_default = true
      run_pull_request_plan_default = true
      force_remote_backend          = true
      drift_detection_cron          = "0 1 * * *"
    }
    Stage = {
      disable_destroy_environments  = false
      number_of_environments        = null
      number_of_environments_total  = null
      requires_approval_default     = false
      default_ttl                   = null
      max_ttl                       = null
      include_cost_estimation       = true
      skip_apply_when_plan_is_empty = true
      skip_redundant_deployments    = true
      continuous_deployment_default = true
      run_pull_request_plan_default = true
      force_remote_backend          = true
      drift_detection_cron          = "0 3 * * 7"
    }
    Prod = {
      disable_destroy_environments  = true
      number_of_environments        = null
      number_of_environments_total  = null
      requires_approval_default     = false
      default_ttl                   = null
      max_ttl                       = null
      include_cost_estimation       = true
      skip_apply_when_plan_is_empty = true
      skip_redundant_deployments    = true
      continuous_deployment_default = true
      run_pull_request_plan_default = true
      force_remote_backend          = true
      drift_detection_cron          = "0 5 * * 7"
    }
  }
  EOT
}

locals {
  # tofu_templates = ["vpc", "ec2", "s3", "random_pet"]

  ## use tofu_templates to define both the template and variables (nested)
  tofu_templates = {
    "vpc" = {
      "getRealVPC" = {
        name  = "getRealVPC"
        type  = "terraform"
        value = "true"
        enum  = [
          "true",
          "false"
        ]
        format = null
      }
      "region" = {
        name  = "region"
        type  = "terraform"
        value = "us-west-2"
        enum  = [
          "us-west-2",
          "us-east-1"
        ]
        format = null
      }
    }
    "ec2" = {
      "instance_type" = {
        name  = "instance_type"
        type  = "terraform"
        value = "t3a.micro"
        enum = [
          "t3a.micro",
          "t3a.small",
          "t3a.medium"
        ]
        format = null
      }
      "vpc_id" = {
        name        = "vpc_id"
        type        = "terraform"
        is_required = true
        format      = null
      }
      "region" = {
        name  = "region"
        type  = "terraform"
        value = "us-west-2"
        enum  = [
          "us-west-2",
          "us-east-1"
        ]
        format = null
      }
    }
    "s3" = {
      "prefix" = {
        name   = "prefix"
        type   = "terraform"
        value  = "env0-s3"
        format = null
      }
      "bucketname" = {
        name   = "bucketname"
        type   = "terraform"
        value  = "bucket"
        format = null
      }
      "region" = {
        name  = "region"
        type  = "terraform"
        value = "us-west-2"
        enum  = [
          "us-west-2",
          "us-east-1"
        ]
        format = null
      }
    }
    "eks_data" = {
      "cluster-name" = {
        name        = "cluster-name"
        type        = "terraform"
        is_required = true
        format      = null
      }
      "region" = {
        name  = "region"
        type  = "terraform"
        value = "us-west-2"
        enum  = [
          "us-west-2",
          "us-east-1"
        ]
        format = null
      }
    }
    "random_pet" = {
      "keeper" = {
        name        = "keeper"
        type        = "terraform"
        format      = null
      }
    }
  }

  template_vars = merge([
    for template_name, template_vars in local.tofu_templates : {
      for var_name, var_data in template_vars : "${template_name}_${var_name}" => merge(var_data, {
        template = template_name
      })
    }
  ]...)
}

# ## Uncomment this to understand the structure of local.template_vars 
# example structure
# {
#   "ec2_instance_type": {
#     "enum": ["t3a.micro", "t3a.small", "t3a.medium"],
#     "format": null,
#     "name": "instance_type",
#     "template": "ec2",
#     "type": "terraform",
#     "value": "t3a.micro"
#   },
#   "ec2_region": {
#     "enum": ["us-west-2", "us-east-1"],
#     "format": null,
#     "name": "region",
#     "template": "ec2",
#     "type": "terraform",
#     "value": "us-west-2"
#   },
#   "ec2_vpc_id": {
#     "format": null,
#     "is_required": true,
#     "name": "vpc_id",
#     "template": "ec2",
#     "type": "terraform"
#   },
#   "vpc_getRealVPC": {
#     "enum": ["true", "false"],
#     "format": null,
#     "name": "getRealVPC",
#     "template": "vpc",
#     "type": "terraform",
#     "value": "true"
#   },
#   "vpc_region": {
#     "enum": ["us-west-2", "us-east-1"],
#     "format": null,
#     "name": "region",
#     "template": "vpc",
#     "type": "terraform",
#     "value": "us-west-2"
#   }
# }
# output "template_var" {
#   value = local.template_vars
# }

resource "env0_template" "template" {
  for_each = local.tofu_templates

  name             = each.key
  description      = "template of ${each.key}"
  repository       = data.env0_template.this.repository
  path             = "${local.modules_dir}/${each.key}"
  type             = "opentofu"
  opentofu_version = "latest"
  revision         = "main"

  # vcs configuration
  github_installation_id = var.vcs == "github" ? data.env0_template.this.github_installation_id : null
  bitbucket_client_key   = var.vcs == "bitbucket" ? data.env0_template.this.bitbucket_client_key : null
  is_azure_devops        = var.vcs == "azure" ? data.env0_template.this.is_azure_devops : null
  token_id               = var.vcs == "gitlab" || var.vcs == "azure" ? data.env0_template.this.token_id : null
  # token_name      = var.vcs == "gitlab" ? data.env0_template.this.token_name : null
  # gitlab_project_id    = var.vcs == "gitlab" ? data.env0_template.this.gitlab_project_id : null
}


resource "env0_configuration_variable" "template_var" {
  for_each = local.template_vars

  template_id = env0_template.template[each.value.template].id

  name        = each.value.name
  type        = each.value.type
  value       = lookup(each.value, "value", null)
  enum        = lookup(each.value, "enum", null)
  format      = lookup(each.value, "format", null)
  is_required = lookup(each.value, "is_required", false)
}
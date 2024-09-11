# Azure SP

This allows env0 (SaaS) to use the azure service-principal created here.

The assume role by should have permissions to do what your Terraform code is doing.
By default, this code assigns it admin privileges.

This code also creates the env0 azure credential - which must later be assigned to the project.

For the sake of simplicity - this code is meant to be used through the user's terminal.

The user should have access to both env0 (API keys) and Azure (through az login) and the ability to create a service principal and assign IAM permissions to a subscription.

## Pre-reqs

ENV0_API_KEY
ENV0_API_SECRET
ENV0_ORGANIZATION_ID
Azure CLI login (az login)
OpenTofu CLI or Terraform CLI

## How To

1. In your terminal, Login to Azure `az login`
2. Select the subscription as part of the az login prompts or `az account set --subscription "<subscription ID or name>"`
3. Set up environment variables:
   a. `export ENV0_API_KEY=<api key>` create an [env0 api key](https://docs.env0.com/docs/api-keys) (either personal or organization) 
   b. `export ENV0_API_SECRET=<api secret>` 
   c. `export ENV0_ORGANIZATION_ID=<your orgid>` retrieve this from your **organization** > **settings** (e.g. bde19c6d-d0dc-4b11-a951-8f43fe49db92)
4. Update default.auto.tfvars values as necessary (review variables.tf to understand what those values mean)
5. Run `tofu apply` 
6. Voila, your env0 org will now have a new Azure Credential configured. Don't forget to assign that credential to your project. 
   Or you can use TF [`env0_cloud_credentials_project_assignment` resource](https://registry.terraform.io/providers/env0/env0/latest/docs/resources/cloud_credentials_project_assignment)

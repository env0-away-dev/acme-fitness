# Azure SP

This allows env0 (SaaS) to use the azure service-principal created here.

The assume role by should have permissions to do what your Terraform code is doing.
By default, this code assigns it admin privileges.

This code also creates the env0 azure credential - which must later be assigned to the project.

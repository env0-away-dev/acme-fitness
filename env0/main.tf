# Create Assume Role
module "pet-name" {
  source = "../modules/random_pet"
}

module "assume-role" {
  source = "./credentials/assume-role"

  assume_role_name      = "env0-deployer-role-${module.pet-name.name}"
  cost_assume_role_name = "env0-cost-role-${module.pet-name.name}"
}
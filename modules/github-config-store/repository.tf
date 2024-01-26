resource "github_repository" "config_store" {
  auto_init        = true 
  description      = "Terraform configuration store for the Pegasus lab."
  has_discussions  = false
  has_downloads    = false
  has_issues       = false
  has_projects     = false
  has_wiki         = false 
  license_template = "mit"
  name             = module.environment.github_config_repository_name
  topics           = ["automation", "config", "terraform"]
}

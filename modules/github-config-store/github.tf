terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

# GITHUB_TOKEN must be set in the environment
provider "github" {
  owner = module.environment.github_repository_owner
}

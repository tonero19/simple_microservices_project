# terraform/main.tf

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    render = {
      source  = "render-oss/render"
      version = "~> 1.9.0"
    }
    neon = {
      source  = "kislerdm/neon"
      version = "~> 0.18.0"
    }
  }

 # Add this block to lock your state to your free Terraform Cloud account
  backend "remote" {
    organization = "Tonero_first_organization"

    workspaces {
      name = "simple-microservices"
    }
  }
}

provider "neon" {
  # Injected securely via NEON_API_KEY environment variable in Terraform Cloud
}

# Create a Free Neon Project
resource "neon_project" "ecommerce_db" {
    name      = "ecommerce-database"
    region_id = "aws-us-west-2"
    org_id    = "org-floral-dust-69666643"
    history_retention_seconds = 21600
}

provider "render" {
  # Automatically handled via RENDER_API_KEY GitHub Secret
}

# 1. Deploy the Product Microservice
resource "render_web_service" "product_service" {
  name           = "product-service"
  plan           = "free"
  region         = "oregon"
  root_directory = "product-service"

  # Newer syntax handles the git repo tracking using a structured runtime source block
  runtime_source = {
    docker = {
      auto_deploy = true
      branch      = "main"
      repo_url    = "https://github.com/tonero19/simple_microservices_project"
    }
  }

  # Environment variables require structured object definitions
  env_vars = {
    "SPRING_PROFILES_ACTIVE" = { value = "prod" }
    "SERVER_PORT"            = { value = "8081" }
    "JVM_OPTS"               = { value = "-XX:+UseSerialGC -Xss512k -Xms128m -Xmx256m" }

    # Clean mapping using explicit computed provider outputs
    "SPRING_DATASOURCE_URL"  = { value = "jdbc:postgresql://${neon_endpoint.db_endpoint.host}/${neon_database.main_db.name}?sslmode=require" }
    "SPRING_DATASOURCE_USER" = { value = neon_role.db_user.name }
    "SPRING_DATASOURCE_PASS" = { value = neon_role.db_user.password }
  }
}

# 2. Deploy the Order Microservice
resource "render_web_service" "order_service" {
  name           = "order-service"
  plan           = "free"
  region         = "oregon"
  root_directory = "order-service"

  runtime_source = {
    docker = {
      auto_deploy = true
      branch      = "main"
      repo_url    = "https://github.com/tonero19/simple_microservices_project"
    }
  }

  env_vars = {
    "SPRING_PROFILES_ACTIVE" = { value = "prod" }
    "SERVER_PORT"            = { value = "8082" }
    "JVM_OPTS"               = { value = "-XX:+UseSerialGC -Xss512k -Xms128m -Xmx256m" }

    "SPRING_DATASOURCE_URL"  = { value = "jdbc:postgresql://${neon_endpoint.db_endpoint.host}/${neon_database.main_db.name}?sslmode=require" }
    "SPRING_DATASOURCE_USER" = { value = neon_role.db_user.name }
    "SPRING_DATASOURCE_PASS" = { value = neon_role.db_user.password }

    # Securely maps your product microservice network endpoint address
    "PRODUCT_SERVICE_URL"    = { value = render_web_service.product_service.url }
  }
}

# Output the live URLs directly to your console
output "product_service_public_url" {
  value       = render_web_service.product_service.url
  description = "The public URL of the Product Microservice"
}

output "order_service_public_url" {
  value       = render_web_service.order_service.url
  description = "The public URL of the Order Microservice"
}


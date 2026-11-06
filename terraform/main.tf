# terraform/main.tf

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    render = {
      source  = "render-oss/render"
      version = "~> 0.1.0"
    }
  }
}

provider "render" {
  # The API Key is injected securely via the RENDER_API_KEY environment variable.
  # Do not hardcode your API keys here!
}

# 1. Group our microservices inside a single environment
resource "render_environment" "ecommerce_dev" {
  name        = "ecommerce-dev"
  protected   = false
}

# 2. Deploy the Product Microservice
resource "render_web_service" "product_service" {
  name        = "product-service"
  plan        = "free" # <--- Forces Render to use its Always Free Tier
  region      = "oregon"
  runtime     = "docker"

  # UPDATE THIS: Point this to your public or private GitHub repository
  repo        = "https://github.com/tonero19/simple_microservices_project"
  branch      = "main"

  # Crucial context: Tells Render which sub-directory contains this service's Dockerfile
  root_directory = "product-service"

  env_vars = {
    "SPRING_PROFILES_ACTIVE" = "prod"
    "SERVER_PORT"            = "8081"
    "JVM_OPTS"               = "-XX:+UseSerialGC -Xss512k -Xms128m -Xmx256m"

    # Optional production database details.
    # For now, it falls back to the local schema fallback if these values are left empty.
    "SPRING_DATASOURCE_URL"  = ""
    "SPRING_DATASOURCE_USER" = ""
    "SPRING_DATASOURCE_PASS" = ""
  }
}

# 3. Deploy the Order Microservice
resource "render_web_service" "order_service" {
  name        = "order-service"
  plan        = "free"
  region      = "oregon"
  runtime     = "docker"

  # UPDATE THIS: Point this to the same repository url
  repo        = "https://github.com/tonero19/simple_microservices_project"
  branch      = "main"

  root_directory = "order-service"

  env_vars = {
    "SPRING_PROFILES_ACTIVE" = "prod"
    "SERVER_PORT"            = "8082"
    "JVM_OPTS"               = "-XX:+UseSerialGC -Xss512k -Xms128m -Xmx256m"

    # Clean Service Discovery: Dynamically maps the live production URL of the Product Service
    # directly into the Order Service's application context.
    "PRODUCT_SERVICE_URL"    = render_web_service.product_service.url
  }
}

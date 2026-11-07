# Serverless Microservices E-Commerce Backend

A 100% free-tier, production-ready microservices architecture built with **Spring Boot 3.x**, **Java 21**, and **PostgreSQL**. The entire cloud cluster infrastructure is provisioned natively via **Terraform** and deployed continuously through **GitHub Actions** onto **Render** and **Neon**.

## 🏗️ Architecture Blueprint

```text
                           ┌─────────────────────────┐
                           │      Public Client      │
                           └────────────┬────────────┘
                                        │ (HTTP REST)
                  ┌─────────────────────┴─────────────────────┐
                  ▼                                           ▼
      ┌──────────────────────┐                    ┌──────────────────────┐
      │   Product Service    │                    │    Order Service     │
      │     (Port 8081)      │                    │     (Port 8082)      │
      └───────────┬──────────┘                    └───────────┬──────────┘
                  │                                           │
                  │             ┌──────────────┐              │
                  └────────────►│ Neon Cloud   │◄─────────────┘
                                │  PostgreSQL  │ (True Persistence)
                                └──────────────┘
```

* **Lean Service Discovery:** Built without heavy infrastructure nodes (like Eureka). Endpoints are wired securely across components via Terraform environment variable injection (`PRODUCT_SERVICE_URL`).
* **Ultra-Low Memory Tuning:** Applications are bundled via multi-stage Docker builds using light Alpine JRE runtimes. Tuned with `SerialGC` to restrict individual microservice footprints to <256MB RAM.

---

## 📁 Repository Structure

```text
📁 ecommerce-microservices
├── 📁 .github/workflows
│   └── 📄 deploy.yml       # GitHub Actions CI/CD pipeline automation
├── 📁 order-service        # Standalone Order handling microservice
│   ├── 📁 src/...          # RestClient inter-service verification logic
│   └── 📄 Dockerfile       # Light Alpine runtime builder
├── 📁 product-service      # Standalone Product catalog microservice
│   ├── 📁 src/...          # Spring Data JPA controllers & repositories
│   └── 📄 Dockerfile       # Multi-stage image build script
└── 📁 terraform
    └── 📄 main.tf          # Unified infrastructure blueprint (Render & Neon)
```

---

## 🚀 Setup & Deployment Pipeline

### 1. Prerequisites & Accounts
* Free accounts on [GitHub](https://github.com), [Render](https://render.com), [Neon.tech](https://neon.tech), and [Terraform Cloud](https://terraform.io).

### 2. Configure Cloud Secrets & Variables

#### Inside Terraform Cloud Workspace (`simple-microservices`):
Add the following as **Environment Variables** (not Terraform variables):
* `RENDER_API_KEY` (Sensitive): Your Render profile token.
* `RENDER_OWNER_ID` (Plain): Your user/team ID hook from the Render dashboard URL.
* `NEON_API_KEY` (Sensitive): Your developer access token from Neon.

#### Inside GitHub Repository Settings (Secrets -> Actions):
Create the following repository secrets:
* `RENDER_API_KEY`: Same Render token as above.
* `RENDER_OWNER_ID`: Same Render Owner ID as above.
* `TF_API_TOKEN`: User API execution token generated from your Terraform Cloud Profile.

### 3. Local Commands & Triggers
To deploy updates to the active cloud stack, simply save your work inside IntelliJ and push directly to your main branch:
```bash
git add .
git commit -m "feat: infrastructure synchronization push"
git push origin main
```

---

## 🧪 Interacting with the Live APIs

Replace `://onrender.com` with the live URL printed out at the end of your successful GitHub Actions plan deployment logs.

### 1. Register a Product (`POST` to Product Service)
```bash
curl -X POST https://onrender.com \
     -H "Content-Type: application/json" \
     -d '{"name": "Mechanical Keyboard", "price": 89.99}'
```

### 2. View Product Catalog (`GET` from Product Service)
```bash
curl https://onrender.com
```

### 3. Submit an Order (`POST` to Order Service)
*This demonstrates full cross-network context verification; the Order Service automatically queries the Product Service to validate the item identity before persisting state to PostgreSQL.*
```bash
curl -X POST https://onrender.com \
     -H "Content-Type: application/json" \
     -d '{"productId": 1, "quantity": 1}'
```

### 4. Audit Active System Orders (`GET` from Order Service)
```bash
curl https://onrender.com
```


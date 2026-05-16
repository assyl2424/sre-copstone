# SRE Capstone Project: Production Readiness Review

This repository contains the complete infrastructure and application code for the SRE Capstone project.

## Project Structure
- `app/`: FastAPI microservice with metrics and load simulation.
- `terraform/`: IaC for Kubernetes resources (Namespaces, Deployment, Service, HPA).
- `.github/workflows/`: CI/CD pipeline for automated build and deploy.
- `monitoring/`: Helm values and configuration for Prometheus & Grafana.
- `load-test/`: Locust script for performance and HPA testing.

## Prerequisites
- Docker & Kubernetes (Minikube recommended)
- Terraform
- Helm

## Step-by-Step Deployment

### 1. Start Minikube
```bash
minikube start
```

### 2. Infrastructure as Code (Terraform)
Initialize and apply the Terraform configuration to create namespaces and the base deployment.
```bash
cd terraform
terraform init
terraform apply -auto-approve
```

### 3. Deploy Observability Stack
Install the Prometheus Community Helm chart with custom values.
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  -f ../monitoring/prometheus-values.yaml
```

### 4. CI/CD Pipeline
The provided GitHub Action `.github/workflows/ci-cd.yml` will automatically:
1. Build the Docker image.
2. Push to GitHub Container Registry (GHCR).
3. Apply Terraform changes.

*Note: You need to set `KUBECONFIG_BASE64` in your GitHub repository secrets.*

### 5. Load Testing & SRE Operations
Run Locust to simulate traffic and observe HPA scaling.
```bash
cd load-test
pip install locust
locust -f locustfile.py
```
Visit `http://localhost:8089` to start the test. Point it to the Orders Service URL (get it via `minikube service orders-service -n production --url`).

## SLIs and SLOs
- **Availability**: 99.9% of requests to `/health` should return 200 OK.
- **Latency**: 95th percentile of requests to `/` should be < 100ms.
- **Error Rate**: < 1% of total requests should result in 5xx errors.

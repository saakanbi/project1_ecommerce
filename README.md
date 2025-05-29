# E-Commerce Backend Project

This project demonstrates a complete CI/CD pipeline for a Spring Boot REST API deployed on AWS EKS.

## Components

- **Spring Boot REST API**: Simple e-commerce backend API
- **Docker**: Application containerization
- **Terraform**: Infrastructure as Code for AWS resources
- **EKS**: Kubernetes cluster on AWS
- **Jenkins**: CI/CD automation
- **Prometheus & Grafana**: Monitoring and observability
- **ALB Ingress Controller**: Expose the application via AWS Application Load Balancer

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed
- kubectl installed
- Docker installed
- Maven installed (for local development)

## Deployment Steps

### 1. Provision Infrastructure with Terraform

```bash
cd terraform
terraform init
terraform apply
```

### 2. Configure kubectl to connect to the EKS cluster

```bash
aws eks update-kubeconfig --region $(terraform output -raw region) --name $(terraform output -raw cluster_name)
```

### 3. Access Jenkins

Jenkins is available at: http://$(terraform output -raw jenkins_public_ip):8080

Initial admin password can be retrieved with:
```bash
ssh -i your-key.pem ec2-user@$(terraform output -raw jenkins_public_ip) 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'
```

### 4. Configure Jenkins Pipeline

1. Install required Jenkins plugins:
   - Docker Pipeline
   - AWS Credentials
   - Kubernetes CLI

2. Add AWS credentials to Jenkins
3. Create a new pipeline job using the Jenkinsfile in this repository

### 5. Access the Application

After successful deployment, the application will be accessible via the ALB URL:

```bash
kubectl get ingress -n default
```

### 6. Access Monitoring

Prometheus and Grafana are deployed in the monitoring namespace:

```bash
# Port forward Prometheus
kubectl port-forward svc/prometheus -n monitoring 9090:9090

# Port forward Grafana
kubectl port-forward svc/grafana -n monitoring 3000:3000
```

Grafana default credentials:
- Username: admin
- Password: admin

## Project Structure

- `src/`: Spring Boot application source code
- `terraform/`: Infrastructure as Code
- `k8s/`: Kubernetes manifests
- `Dockerfile`: Container definition
- `Jenkinsfile`: CI/CD pipeline definition
- `pom.xml`: Maven project configuration
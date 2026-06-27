# **🚀 Deploying Super Mario on AWS EKS using Terraform**  

Super Mario is a legendary game we all cherish! In this project, we will deploy **Super Mario** on **Amazon EKS (Elastic Kubernetes Service)** using **Terraform** and manage infrastructure with AWS resources.  

![Super Mario](https://imgur.com/Njqsei9.gif)  

---

## 📌 **Project Overview**

This project provisions an **EKS cluster** on AWS and deploys the **Super Mario game** using **Terraform** and **Kubernetes manifests**. The deployment includes:

- ✅ **Amazon EKS Cluster** (v1.36) with dual authentication (API + ConfigMap)
- ✅ **Terraform Infrastructure as Code** (v1.10+)
- ✅ **Custom multi-AZ VPC** (`previselab-vpc`) with public/private subnet separation
- ✅ **Modular Terraform structure** — separate VPC and EKS modules
- ✅ **Multi-environment support** — dev / stg / prd via `envs/` tfvars files
- ✅ **AWS S3 Backend** with native state locking (`use_lockfile`) — no DynamoDB required
- ✅ **IAM roles & policies** with least-privilege access
- ✅ **AWS Load Balancer Controller** IAM policy created via Terraform
- ✅ **CloudWatch logging** and monitoring
- ✅ **Horizontal Pod Autoscaling** for automatic scaling
- ✅ **Dedicated Kubernetes namespace** (`previselab`) for all resources
- ✅ **Network policies** for enhanced security
- ✅ **ServiceMonitor** for Prometheus integration
- ✅ **Health checks** and rolling updates

---

## **📁 Project Structure**  

```bash
📂 DEPLOYMENT-OF-SUPER-MARIO
├── 📂 bootstrap                       # Run once to create S3 bucket + IAM policy
│   ├── main.tf                        # S3 bucket, versioning, encryption, IAM policy
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── 📂 EKS-TF                          # Terraform configuration
│   ├── backend.tf                     # S3 backend with native use_lockfile locking
│   ├── provider.tf                    # AWS/Kubernetes provider configuration
│   ├── main.tf                        # Root module — calls vpc and eks modules
│   ├── variables.tf                   # Input variable definitions
│   ├── outputs.tf                     # Output values after deployment
│   ├── terraform.tfvars               # Production baseline defaults
│   ├── 📂 envs/
│   │   ├── dev.tfvars                 # Development environment overrides
│   │   ├── stg.tfvars                 # Staging environment overrides
│   │   └── prd.tfvars                 # Production environment overrides
│   ├── 📂 modules/
│   │   ├── 📂 vpc/                    # Custom VPC module (previselab-vpc)
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   └── 📂 eks/                    # EKS cluster + node group module
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       └── lb_controller_policy.json
│   └── 📂 k8s/                        # Kubernetes manifests
│       ├── namespace.yaml             # previselab namespace definition
│       ├── deployment.yaml            # Kubernetes Deployment for Super Mario
│       ├── service.yaml               # Kubernetes Service (NLB, internet-facing)
│       ├── horizontal-pod-autoscaler.yaml # HPA for automatic scaling
│       ├── network-policy.yaml        # Network security policies
│       └── service-monitor.yaml      # Prometheus monitoring configuration
└── 📄 README.md                       # Project documentation
```

---

## **📌 Prerequisites**  

Before proceeding, ensure you have the following installed:

- ✅ **Terraform** (>=1.10.0)  
- ✅ **AWS CLI** (Configured with proper credentials)  
- ✅ **kubectl** (For managing Kubernetes resources)  
- ✅ **Docker** (For containerization)  
- ✅ **AWS Key Pair** (optional — set `ssh_key_name` in the relevant tfvars to enable SSH; nodes default to SSM access)

---

## **🛠️ Setup & Deployment**  

### **1️⃣ Choose Your Environment**

The project supports three environments, each with its own VPC CIDR space and sizing:

| Environment | Cluster | VPC CIDR | Instance | Nodes |
|---|---|---|---|---|
| dev | EKS_MARIO_DEV | 10.10.0.0/16 | t3.small | 1–2 |
| stg | EKS_MARIO_STG | 10.20.0.0/16 | t3.medium | 1–3 |
| prd | EKS_MARIO | 10.30.0.0/16 | t3.medium | 1–4 |

### **2️⃣ Bootstrap — Create S3 State Bucket (first-time only)**

Run this **once** before the main Terraform deployment to create the S3 bucket and IAM policy used by the backend:

```bash
cd bootstrap
terraform init
terraform apply -auto-approve
```

After apply, note the `terraform_s3_backend_policy_arn` output and attach it to the IAM user/role used by the `previse` AWS profile:

```bash
# If using an IAM user:
aws iam attach-user-policy \
  --user-name <your-iam-user> \
  --policy-arn <terraform_s3_backend_policy_arn output> \
  --profile previse

# If using an IAM role:
aws iam attach-role-policy \
  --role-name <your-iam-role> \
  --policy-arn <terraform_s3_backend_policy_arn output> \
  --profile previse
```

### **3️⃣ Initialize & Apply Terraform**  

```bash
cd EKS-TF

terraform init

# Development
terraform plan  -var-file=envs/dev.tfvars
terraform apply -var-file=envs/dev.tfvars -auto-approve

# Staging
terraform plan  -var-file=envs/stg.tfvars
terraform apply -var-file=envs/stg.tfvars -auto-approve

# Production
terraform plan  -var-file=envs/prd.tfvars
terraform apply -var-file=envs/prd.tfvars -auto-approve
```

### **4️⃣ Configure Kubernetes Context**  

```bash
aws eks update-kubeconfig --name EKS_MARIO --region us-east-1 --profile previse
# For dev: --name EKS_MARIO_DEV
# For stg: --name EKS_MARIO_STG
```

### **5️⃣ Deploy Super Mario Application**  

Create the namespace first, then apply all manifests:

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/
```

Or apply individually:

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/horizontal-pod-autoscaler.yaml
kubectl apply -f k8s/network-policy.yaml
# Optional: Apply if you have Prometheus installed
kubectl apply -f k8s/service-monitor.yaml
```

### **6️⃣ Access the Application**  

Once deployed, get the external LoadBalancer URL:  

```bash
kubectl get services mario-service -n previselab
```

Access **Super Mario** in your browser using the displayed URL.

### **7️⃣ Monitor the Deployment**  

```bash
# Check deployment status
kubectl get deployment mario-deployment -n previselab

# Check pods
kubectl get pods -l app=mario -n previselab

# Check HPA status
kubectl get hpa mario-hpa -n previselab

# Check logs
kubectl logs -l app=mario -n previselab --tail=50

# Check autoscaling events
kubectl describe hpa mario-hpa -n previselab
```

### **8️⃣ Teardown (Destroy Infrastructure)**

> **Important:** Always delete Kubernetes `LoadBalancer` services before running `terraform destroy`.
> When a Kubernetes Service of type `LoadBalancer` is deployed, AWS creates an ELB **outside of
> Terraform's state**. On destroy, Terraform deletes the VPC before Kubernetes cleans up the
> ELB's ENIs — leaving the Internet Gateway attached and blocking VPC deletion with a
> `DependencyViolation` error.

```bash
kubectl delete svc --all -n previselab
# wait ~30s for the ELB to drain, then:
terraform destroy -var-file=envs/dev.tfvars
```

If you already hit the `DependencyViolation` error, manually detach and delete the orphaned
Internet Gateway via the AWS Console or CLI, then re-run `terraform destroy`:

```bash
# Find the IGW still attached to the VPC
aws ec2 describe-internet-gateways \
  --filters "Name=attachment.vpc-id,Values=<vpc-id>" \
  --query "InternetGateways[*].InternetGatewayId" \
  --output text --profile previse

# Detach and delete it
aws ec2 detach-internet-gateway --internet-gateway-id <igw-id> --vpc-id <vpc-id> --profile previse
aws ec2 delete-internet-gateway --internet-gateway-id <igw-id> --profile previse

# Now retry destroy
terraform destroy -var-file=envs/dev.tfvars
```

---

## **🎯 Project Highlights**

- **AWS EKS v1.36**: Managed Kubernetes with `API_AND_CONFIG_MAP` dual authentication
- **Terraform v1.10+**: S3 native state locking (`use_lockfile = true`) — no DynamoDB table needed
- **Custom VPC (`previselab-vpc`)**: Public + private subnets across 3 AZs; NAT Gateway per AZ for HA
- **Private node placement**: EKS nodes in private subnets; NLB in public subnets
- **Modular IaC**: Separate `modules/vpc` and `modules/eks` for reusability
- **Multi-environment**: dev / stg / prd with isolated CIDR spaces via `envs/` tfvars
- **LB Controller IAM policy**: Created directly in Terraform (no manual pre-requisite)
- **CloudWatch Logging**: Centralized control plane log collection
- **Auto Scaling**: Horizontal Pod Autoscaler for dynamic resource management
- **Network Security**: Network policies and security group controls
- **Monitoring Ready**: Prometheus integration via ServiceMonitor

---

## **🔧 Configuration Details**

### **VPC — previselab-vpc**
- **CIDR**: per environment (dev: `10.10.0.0/16`, stg: `10.20.0.0/16`, prd: `10.30.0.0/16`)
- **Subnets**: 3 public + 3 private, one per AZ (`us-east-1a/b/c`)
- **NAT Gateways**: one per AZ for high-availability egress from private subnets
- **EKS subnet tags**: `kubernetes.io/role/elb` (public) and `kubernetes.io/role/internal-elb` (private)

### **EKS Cluster Configuration**
- **Version**: 1.36
- **Authentication**: `API_AND_CONFIG_MAP` — supports both EKS Access Entries API and `aws-auth` ConfigMap
- **Node placement**: private subnets only
- **Endpoint access**: private + public (restrict `public_access_cidrs` in production)
- **Logging**: all control plane log types enabled (api, audit, authenticator, controllerManager, scheduler)

### **Node Group**
- **Instance**: t3.medium (prd/stg), t3.small (dev)
- **Scaling**: 1–4 nodes (prd), 1–2 (dev)
- **AMI**: AL2023_x86_64_STANDARD, ON_DEMAND capacity
- **Storage**: 30 GiB (prd/stg), 20 GiB (dev)

### **Kubernetes Resources** (`k8s/`)
- **Namespace**: `previselab` — all resources are scoped to this namespace
- **Manifests**: `namespace.yaml`, `deployment.yaml`, `service.yaml`, `horizontal-pod-autoscaler.yaml`, `network-policy.yaml`, `service-monitor.yaml`
- **Replicas**: 3 pods with auto-scaling up to 10
- **Resources**: CPU requests 100m, limits 500m; Memory requests 128Mi, limits 512Mi
- **Health Checks**: Liveness, readiness, and startup probes
- **Security**: Security contexts with non-root user

### **State Management**
- **Backend**: S3 (`mario-12-bucket-tf-state-shared`, `eks/terraform.tfstate`)
- **Locking**: S3 native `use_lockfile = true` (Terraform 1.10+)
- **Encryption**: AES-256 server-side encryption
- **Bucket provisioning**: managed by `bootstrap/` (run once before `EKS-TF/`)

---

## **🔗 Resources & Documentation**

- **Terraform Docs**: [https://developer.hashicorp.com/terraform/docs](https://developer.hashicorp.com/terraform/docs)  
- **AWS EKS Docs**: [https://docs.aws.amazon.com/eks/latest/userguide](https://docs.aws.amazon.com/eks/latest/userguide)  
- **Kubernetes Docs**: [https://kubernetes.io/docs/home/](https://kubernetes.io/docs/home/)  
- **AWS Load Balancer Controller**: [https://kubernetes-sigs.github.io/aws-load-balancer-controller/](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)  
- **Prometheus Monitoring**: [https://prometheus.io/docs/](https://prometheus.io/docs/)  

---

## **📢 Credits & Acknowledgments**  

This project is inspired by the **Super Mario** game, and it demonstrates real-world **DevOps practices** using AWS, Terraform, and Kubernetes.  

👉 **Read the detailed blog here**: [Super Mario EKS Deployment](https://blog.prodevopsguy.xyz/deployment-of-super-mario-on-kubernetes-using-terraform)  

🚀 *Happy Gaming & DevOps-ing!* 🎮

---

## 🤝 **Contributing**  

Contributions are welcome! If you'd like to improve this project, feel free to submit a pull request.  

---

## **Hit the Star!** ⭐

**If you find this repository helpful and plan to use it for learning, please give it a star. Your support is appreciated!**

---

## 🛠️ **Author & Community**  

This project is crafted by **[PetersonOlay](https://github.com/PetersonOlay)** 💡.  
I'd love to hear your feedback! Feel free to share your thoughts.  

---

### 📧 **Connect with me:**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-%230077B5.svg?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/harshhaa-vardhan-reddy) [![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/NotHarshhaa)  [![Telegram](https://img.shields.io/badge/Telegram-26A5E4?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/prodevopsguy) [![Dev.to](https://img.shields.io/badge/Dev.to-0A0A0A?style=for-the-badge&logo=dev.to&logoColor=white)](https://dev.to/notharshhaa) [![Hashnode](https://img.shields.io/badge/Hashnode-2962FF?style=for-the-badge&logo=hashnode&logoColor=white)](https://hashnode.com/@prodevopsguy)  

---

### 📢 **Stay Connected**  

![Follow Me](https://imgur.com/2j7GSPs.png)

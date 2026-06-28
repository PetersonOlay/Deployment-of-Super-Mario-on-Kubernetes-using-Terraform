# 🚀 Deploying Super Mario on AWS EKS using Terraform

This project provisions a production-grade **Amazon EKS** cluster on AWS and deploys the Super Mario game using **Terraform** and **Kubernetes** manifests.

![Super Mario](https://imgur.com/Njqsei9.gif)

---

## Project Overview

The deployment includes:

- Amazon EKS Cluster (v1.36) with dual authentication (API + ConfigMap)
- Terraform Infrastructure as Code (v1.10+)
- Custom multi-AZ VPC (`previselab-vpc`) with public/private subnet separation
- Modular Terraform structure — separate VPC and EKS modules
- Multi-environment support — dev / stg / prd via `envs/` tfvars files
- AWS S3 backend with native state locking (`use_lockfile`) — no DynamoDB required
- IAM roles and policies with least-privilege access
- AWS Load Balancer Controller IAM policy created via Terraform
- CloudWatch logging and monitoring
- Horizontal Pod Autoscaling for automatic scaling
- Dedicated Kubernetes namespace (`previselab`) for all resources
- Network policies for enhanced security
- ServiceMonitor for Prometheus integration
- Health checks and rolling updates

---

## Project Structure

```bash
DEPLOYMENT-OF-SUPER-MARIO/
├── bootstrap/                         # Run once to create S3 bucket + IAM policy
│   ├── main.tf                        # S3 bucket, versioning, encryption, IAM policy
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── EKS-TF/                            # Main Terraform configuration
│   ├── backend.tf                     # S3 backend with native use_lockfile locking
│   ├── provider.tf                    # AWS/Kubernetes provider configuration
│   ├── main.tf                        # Root module — calls vpc and eks modules
│   ├── variables.tf                   # Input variable definitions
│   ├── outputs.tf                     # Output values after deployment
│   ├── terraform.tfvars               # Production baseline defaults
│   ├── envs/
│   │   ├── dev.tfvars                 # Development environment overrides
│   │   ├── stg.tfvars                 # Staging environment overrides
│   │   └── prd.tfvars                 # Production environment overrides
│   ├── modules/
│   │   ├── vpc/                       # Custom VPC module (previselab-vpc)
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   └── eks/                       # EKS cluster + node group module
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       └── lb_controller_policy.json
│   └── k8s/                           # Kubernetes manifests
│       ├── namespace.yaml             # previselab namespace definition
│       ├── deployment.yaml            # Kubernetes Deployment for Super Mario
│       ├── service.yaml               # Kubernetes Service (NLB, internet-facing)
│       ├── configmap.yaml             # Default ConfigMap (NODE_ENV)
│       ├── horizontal-pod-autoscaler.yaml
│       ├── network-policy.yaml        # Network security policies
│       ├── service-monitor.yaml       # Prometheus ServiceMonitor (optional)
│       └── envs/
│           ├── dev-configmap.yaml
│           ├── stg-configmap.yaml
│           └── prd-configmap.yaml
└── README.md
```

---

## Prerequisites

Before proceeding, ensure you have the following installed:

- **Terraform** >= 1.10.0
- **AWS CLI** configured with the `previse` profile
- **kubectl** for managing Kubernetes resources
- **AWS Key Pair** (optional — set `ssh_key_name` in the relevant tfvars to enable SSH; nodes default to SSM access)

---

## Setup & Deployment

### Step 1 — Choose Your Environment

The project supports three environments, each with its own VPC CIDR space and sizing:

| Environment | Cluster | VPC CIDR | Instance | Nodes |
|---|---|---|---|---|
| dev | EKS_MARIO_DEV | 10.10.0.0/16 | t3.small | 1–2 |
| stg | EKS_MARIO_STG | 10.20.0.0/16 | t3.medium | 1–3 |
| prd | EKS_MARIO | 10.30.0.0/16 | t3.medium | 1–4 |

### Step 2 — Bootstrap (first-time only)

Run this once before the main Terraform deployment to create the S3 bucket and IAM policy used by the backend:

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

### Step 3 — Initialize & Apply Terraform

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

### Step 4 — Configure Kubernetes Context

```bash
aws eks update-kubeconfig --name EKS_MARIO --region us-east-1 --profile previse
# For dev: --name EKS_MARIO_DEV
# For stg: --name EKS_MARIO_STG
```

### Step 5 — Deploy Super Mario Application

Apply the environment-specific ConfigMap first so `NODE_ENV` is set correctly before the pods start:

```bash
kubectl apply -f k8s/namespace.yaml

# Apply the ConfigMap for your target environment
kubectl apply -f k8s/envs/dev-configmap.yaml   # development
# kubectl apply -f k8s/envs/stg-configmap.yaml # staging
# kubectl apply -f k8s/envs/prd-configmap.yaml # production

kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/horizontal-pod-autoscaler.yaml
kubectl apply -f k8s/network-policy.yaml
```

> **Note:** `service-monitor.yaml` requires the **Prometheus Operator** CRD (`monitoring.coreos.com/v1`).
> Install it first, then apply:
>
> ```bash
> helm install prometheus prometheus-community/kube-prometheus-stack \
>   -n monitoring --create-namespace
> kubectl apply -f k8s/service-monitor.yaml
> ```

### Step 6 — Access the Application

Once deployed, get the external LoadBalancer URL:

```bash
kubectl get services mario-service -n previselab
```

Open the displayed URL in your browser to play Super Mario.

### Step 7 — Monitor the Deployment

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

### Step 8 — Teardown

> **Important:** Always delete Kubernetes `LoadBalancer` services before running `terraform destroy`.
> When a Kubernetes Service of type `LoadBalancer` is deployed, AWS creates an ELB outside of
> Terraform's state. On destroy, Terraform deletes the VPC before Kubernetes cleans up the
> ELB's ENIs — leaving the Internet Gateway attached and blocking VPC deletion with a
> `DependencyViolation` error.

```bash
kubectl delete svc --all -n previselab
# Wait ~30s for the ELB to drain, then:
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

# Retry destroy
terraform destroy -var-file=envs/dev.tfvars
```

---

## Troubleshooting

### IAM principal doesn't have access to Kubernetes objects

```
Your current IAM principal doesn't have access to Kubernetes objects on this cluster.
This might be due to the current principal not having an IAM access entry
with permissions to access the cluster.
```

**Cause:** The kubeconfig was generated without the `--profile` flag, so kubectl authenticates as a different IAM identity than the one that created the cluster.

**Fix:** Regenerate the kubeconfig with the correct profile:

```bash
aws eks update-kubeconfig --name EKS_MARIO_DEV --region us-east-1 --profile previse
# Verify access
kubectl get nodes
```

If the error persists, the IAM principal needs an EKS access entry. The Terraform EKS module already creates one automatically for the caller identity via `aws_eks_access_entry`. Run `terraform apply` again to ensure it has been applied.

---

### S3 backend 403 Forbidden on terraform init

```
Error refreshing state: Unable to access object "eks/terraform.tfstate"
in S3 bucket: api error Forbidden
```

**Cause:** The S3 bucket doesn't exist or the IAM user lacks bucket permissions.

**Fix:** Run the bootstrap workspace first:

```bash
cd bootstrap
terraform init && terraform apply -auto-approve
# Attach the output policy ARN to your IAM user
aws iam attach-user-policy --user-name <iam-user> \
  --policy-arn <terraform_s3_backend_policy_arn> --profile previse
```

---

### EKS node group error: KeyPair not found

```
InvalidParameterException: KeyPair eks-key not found
```

**Cause:** `ssh_key_name` is set to a key pair that doesn't exist in AWS.

**Fix:** Set `ssh_key_name = null` in the relevant `envs/*.tfvars` file to disable SSH (nodes are accessible via SSM Session Manager). To enable SSH, create the key pair in EC2 first.

---

### CrashLoopBackOff — nginx Permission denied

```
mkdir() "/var/cache/nginx/client_temp" failed (13: Permission denied)
chown("/var/cache/nginx/client_temp", 101) failed (1: Operation not permitted)
setgid(101) failed (1: Operation not permitted)
```

**Cause:** The `sevenajay/mario` image runs nginx, which requires specific Linux capabilities that were dropped by the security context.

**Fix:** The deployment security context is already configured with the required capabilities (`NET_BIND_SERVICE`, `CHOWN`, `SETGID`, `SETUID`) and `runAsUser: 0`. If you see this error, ensure you are running the latest version of `deployment.yaml`.

---

### ServiceMonitor CRD not found

```
no matches for kind "ServiceMonitor" in version "monitoring.coreos.com/v1"
```

**Cause:** The Prometheus Operator is not installed — it provides the `ServiceMonitor` CRD.

**Fix:** Install the Prometheus Operator first, then apply the manifest:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace
kubectl apply -f k8s/service-monitor.yaml
```

---

## Project Highlights

- **AWS EKS v1.36** — Managed Kubernetes with `API_AND_CONFIG_MAP` dual authentication
- **Terraform v1.10+** — S3 native state locking (`use_lockfile = true`) — no DynamoDB table needed
- **Custom VPC (`previselab-vpc`)** — Public + private subnets across 3 AZs; NAT Gateway per AZ for HA
- **Private node placement** — EKS nodes in private subnets; NLB in public subnets
- **Modular IaC** — Separate `modules/vpc` and `modules/eks` for reusability
- **Multi-environment** — dev / stg / prd with isolated CIDR spaces via `envs/` tfvars
- **LB Controller IAM policy** — Created directly in Terraform, no manual prerequisite
- **CloudWatch Logging** — Centralized control plane log collection
- **Auto Scaling** — Horizontal Pod Autoscaler for dynamic resource management
- **Network Security** — Network policies and security group controls
- **Monitoring Ready** — Prometheus integration via ServiceMonitor

---

## Configuration Details

### VPC — previselab-vpc

- **CIDR**: per environment (dev: `10.10.0.0/16`, stg: `10.20.0.0/16`, prd: `10.30.0.0/16`)
- **Subnets**: 3 public + 3 private, one per AZ (`us-east-1a/b/c`)
- **NAT Gateways**: one per AZ for high-availability egress from private subnets
- **EKS subnet tags**: `kubernetes.io/role/elb` (public) and `kubernetes.io/role/internal-elb` (private)

### EKS Cluster

- **Version**: 1.36
- **Authentication**: `API_AND_CONFIG_MAP` — supports both EKS Access Entries API and `aws-auth` ConfigMap
- **Node placement**: private subnets only
- **Endpoint access**: private + public (restrict `public_access_cidrs` in production)
- **Logging**: all control plane log types enabled (api, audit, authenticator, controllerManager, scheduler)

### Node Group

- **Instance**: t3.medium (prd/stg), t3.small (dev)
- **Scaling**: 1–4 nodes (prd), 1–2 (dev)
- **AMI**: AL2023_x86_64_STANDARD, ON_DEMAND capacity
- **Storage**: 30 GiB (prd/stg), 20 GiB (dev)

### Kubernetes Resources (`k8s/`)

- **Namespace**: `previselab` — all resources are scoped to this namespace
- **Replicas**: 3 pods with auto-scaling up to 10
- **Resources**: CPU requests 100m, limits 500m; Memory requests 128Mi, limits 512Mi
- **Health Checks**: Liveness, readiness, and startup probes on port 80
- **Security**: Security contexts with required nginx capabilities (`NET_BIND_SERVICE`, `CHOWN`, `SETGID`, `SETUID`)

### State Management

- **Backend**: S3 (`mario-12-bucket-tf-state-shared`, key: `eks/terraform.tfstate`)
- **Locking**: S3 native `use_lockfile = true` (Terraform 1.10+)
- **Encryption**: AES-256 server-side encryption
- **Bucket provisioning**: managed by `bootstrap/` (run once before `EKS-TF/`)

---

## Resources

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [AWS EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [Prometheus Monitoring](https://prometheus.io/docs/)

---

## Contributing

Contributions are welcome. If you'd like to improve this project, feel free to submit a pull request to the [project repository](https://github.com/PetersonOlay/Deployment-of-Super-Mario-on-Kubernetes-using-Terraform).

---

## Hit the Star

If you find this repository helpful, please give it a [star](https://github.com/PetersonOlay/Deployment-of-Super-Mario-on-Kubernetes-using-Terraform). Your support is appreciated.

---

## Author

Built by **[PetersonOlay](https://github.com/PetersonOlay)**.

- GitHub: [github.com/PetersonOlay](https://github.com/PetersonOlay)
- LinkedIn: [linkedin.com/in/peter-olay-745b05292](https://www.linkedin.com/in/peter-olay-745b05292/)
- Website: [peterolay.previselab.com](https://peterolay.previselab.com)

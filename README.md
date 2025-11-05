# AWS EKS Cluster Deployment with Terraform Automation

A production-ready, fully automated solution for provisioning secure, scalable Amazon EKS clusters using Terraform Infrastructure as Code (IaC) best practices.

## 🎯 Project Overview

This repository demonstrates enterprise-grade automation for deploying Amazon EKS clusters on AWS. The solution provisions a custom VPC with multi-tier subnet design, configures highly available managed node groups with spot instances for cost optimization, and integrates essential Kubernetes add-ons. Built entirely with Terraform, this IaC approach ensures reproducibility, version control, and collaborative team deployments at scale.

## ✨ Key Features

- **Custom VPC Architecture**: Public, private, and intra subnets for network isolation and security
- **Managed Node Groups**: Auto-scaling with mixed on-demand and spot instances for cost efficiency
- **Kubernetes Add-ons**: CoreDNS (DNS resolution), kube-proxy (networking), AWS VPC CNI (pod networking)
- **Infrastructure as Code**: 100% Terraform-driven infrastructure for reproducibility and auditability
- **High Availability**: Multi-AZ deployment for disaster recovery and reliability
- **Security-First Design**: IAM roles, security groups, VPC isolation, encrypted volumes, secret management
- **Remote State Management**: S3/DynamoDB backend for team collaboration and state locking

## 🛠️ Tech Stack

- **Infrastructure Provisioning**: Terraform 1.0+
- **Cloud Provider**: Amazon Web Services (AWS)
- **Container Orchestration**: Amazon EKS (Kubernetes 1.31+)
- **Compute**: EC2 (managed node groups)
- **Networking**: VPC, subnets, route tables, security groups
- **State Management**: Amazon S3 (state storage), DynamoDB (locking)
- **Automation**: Shell scripting for deployment workflows
- **Version Control**: Git/GitHub

## 📋 Prerequisites

- Terraform >= 1.0 installed locally
- AWS CLI v2 configured with credentials
- Active AWS account with appropriate IAM permissions
- kubectl CLI for cluster interaction (optional)
- Git for version control

## 🚀 Quick Start

### 1. Clone the Repository

git clone https://github.com/Krishna7031/terraform-eks.git
cd terraform-eks

### 2. Configure AWS Credentials

aws configure

Enter AWS Access Key ID, Secret Key, region, output format

### 3. Initialize Remote State Backend

Create S3 bucket and DynamoDB table for remote state management:

cd backend/
terraform init
terraform apply

Output: S3 bucket name and DynamoDB table name
cd ..

### 4. Set Up Environment Variables

Edit `environments/dev/terraform.tfvars`:

region = "us-east-1"
cluster_name = "aws-eks-cluster-1"
kubernetes_version = "1.31"

VPC Configuration
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
intra_subnet_cidrs = ["10.0.20.0/24", "10.0.21.0/24"]

Node Group Configuration
node_desired_size = 2
node_min_size = 1
node_max_size = 4
node_instance_types = ["t3.medium", "t3.small"]
use_spot_instances = true

Tags
environment = "dev"
project_name = "eks-terraform"

### 5. Initialize Terraform

terraform init
-backend-config="bucket=your-eks-state-bucket"
-backend-config="key=eks/dev/terraform.tfstate"
-backend-config="region=us-east-1"
-backend-config="dynamodb_table=eks-terraform-lock"

### 6. Plan and Deploy

Review planned infrastructure changes
terraform plan -var-file="environments/dev/terraform.tfvars" -out=tfplan

Apply the configuration
terraform apply tfplan

Outputs will display:
- EKS Cluster Name
- Cluster Endpoint
- Certificate Authority

### 7. Configure kubectl Access

Update kubeconfig with cluster credentials
aws eks update-kubeconfig
--name aws-eks-cluster-1
--region us-east-1

Verify cluster access
kubectl get nodes
kubectl get pods -n kube-system

### 8. Verify Cluster Add-ons

Check installed add-ons
kubectl get pods -n kube-system | grep -E "coredns|kube-proxy"

Verify VPC CNI is working
kubectl get daemonset -n kube-system aws-node

## 🔑 Key Implementations

### Custom VPC Design

The VPC is organized into three subnet tiers for security and operational isolation:

| Subnet Type | Purpose | Routing | NACL |
|------------|---------|---------|------|
| **Public** | NAT Gateways, Bastion Hosts, ALB | Routes to IGW | Open to Internet |
| **Private** | EKS nodes, pod networking | Routes to NAT | Restricted egress |
| **Intra** | Databases, internal services | Local only | No external access |

Benefits:
- Pods run on private subnets, preventing direct internet exposure
- Egress through NAT Gateway for secure outbound traffic
- Intra subnets for internal databases (RDS, ElastiCache)

### Managed Node Groups with Spot Instances

**Configuration:**
- Mix of on-demand and spot instances for cost optimization
- Auto Scaling Group handles dynamic scaling
- Spot instances reduce costs by 70-90% compared to on-demand

**Cost Savings Example:**
On-Demand t3.medium: $0.0416/hour
Spot t3.medium: $0.0125/hour (70% savings)

### Cluster Add-ons Integration

All add-ons are provisioned and managed through Terraform:

cluster_addons = {
coredns = {
most_recent = true
configuration_values = jsonencode({
computeType = "ec2"
resources = {
limits = { cpu = "100m", memory = "150Mi" }
requests = { cpu = "100m", memory = "150Mi" }
}
})
}

kube_proxy = {
most_recent = true
}

vpc_cni = {
most_recent = true
service_account_role_arn = aws_iam_role.vpc_cni.arn
}
}


### Infrastructure as Code Best Practices

- **Modular Design**: Separate modules for VPC, EKS, IAM, security
- **State Management**: Remote backend prevents accidental state loss
- **Version Control**: All infrastructure changes tracked in Git
- **Declarative Approach**: Terraform manages desired state, not imperative steps
- **Reproducibility**: Same code = identical infrastructure across environments

## 🎓 Key Learnings

✅ **EKS Cluster Architecture**: Understood how Kubernetes control plane works on AWS  
✅ **Network Design**: Designed multi-tier VPC for security and cost optimization  
✅ **Managed Services**: Leveraged AWS-managed control plane for operational simplicity  
✅ **Cost Optimization**: Implemented spot instances for 70%+ savings  
✅ **Kubernetes Networking**: Integrated AWS VPC CNI for pod-to-pod communication  
✅ **Infrastructure Automation**: Achieved reproducible, auditable deployments  
✅ **Team Collaboration**: Used remote state and locking for safe concurrent changes  

## 📈 Scaling Considerations

For production deployments:

Auto-scaling based on metrics
cluster_autoscaler_enabled = true

Ingress controller for external traffic
alb_ingress_controller_enabled = true

Monitoring and logging
enable_cluster_logging = true
log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

Pod disruption budgets for high availability

## 🐛 Troubleshooting

**Node not joining cluster?**
Check node IAM role policies
aws iam list-attached-role-policies --role-name <node-role-name>

Check security group rules
aws ec2 describe-security-groups --group-ids <sg-id>

**Pods stuck in pending?**
Check node capacity
kubectl describe nodes

Check VPC CNI plugin
kubectl logs -n kube-system -l k8s-app=aws-node

**State lock timeout?**
Force unlock (use with extreme caution)
terraform force-unlock <LOCK_ID>


## 🔒 Security Best Practices

- ✅ Cluster encryption at rest
- ✅ Pod security policies enforced
- ✅ RBAC for fine-grained access control
- ✅ VPC flow logs for network auditing
- ✅ Secrets encrypted in etcd
- ✅ EBS volumes encrypted by default
- ✅ `.gitignore` prevents secret exposure

## 📄 License

Apache 2.0

---

**Project Duration**: July 2025  
**Repository**: [GitHub Link](https://github.com/Krishna7031/terraform-eks)  
**Skills Demonstrated**: Terraform · AWS EKS · VPC Networking · Infrastructure as Code · Kubernetes · AWS Best Practices · DevOps

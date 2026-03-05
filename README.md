# 🚀 aws-gitops-infra

> Production-grade GitOps infrastructure automation using Terraform + AWS CodePipeline.
> Every Git push automatically provisions real AWS infrastructure — zero manual clicks.

---

## 📌 What This Project Does

This project implements a **GitOps workflow** where:
- Infrastructure is defined as code using **Terraform**
- Every `git push` to `main` triggers **AWS CodePipeline**
- CodeBuild runs `terraform plan` + `terraform apply` automatically
- All changes are **audited** via CloudTrail

---

## 🏗️ Architecture
```
GitHub (Terraform code)
        │
        ▼
AWS CodePipeline (triggered on push)
        │
        ├── Stage 1: Source (GitHub)
        └── Stage 2: Deploy (CodeBuild → terraform apply)
                │
                ▼
        ┌───────────────────────┐
        │        VPC            │
        │  ┌─────────────────┐  │
        │  │  Public Subnet  │  │
        │  │  EC2 t3.micro   │  │
        │  │  Apache Server  │  │
        │  └─────────────────┘  │
        │  Internet Gateway     │
        │  Security Groups      │
        └───────────────────────┘
                │
        CloudTrail (audit every change)
        S3 + DynamoDB (remote state)
```

---

## ☁️ AWS Services Used

| Service | Purpose |
|---|---|
| VPC | Private network |
| EC2 (t3.micro) | Web server |
| S3 | Terraform remote state + CloudTrail logs |
| DynamoDB | Terraform state locking |
| CodePipeline | GitOps automation |
| CodeBuild | Run terraform plan/apply |
| CloudTrail | Audit every AWS API call |
| IAM | Least-privilege roles |
| CodeStar Connections | GitHub integration |

---

## 🛠️ Tech Stack

- **Terraform** v1.14.6
- **AWS** (ap-south-1 / Mumbai)
- **GitHub** (source of truth)
- **Apache HTTP Server** (on EC2)

---

## 📁 Project Structure
```
aws-gitops-infra/
├── main.tf              # Root module
├── providers.tf         # AWS provider config
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── backend.tf           # S3 remote state
├── iam.tf               # IAM roles & policies
├── codebuild.tf         # CodeBuild project
├── codepipeline.tf      # CodePipeline config
├── cloudtrail.tf        # Audit trail
├── buildspec.yml        # CodeBuild instructions
└── modules/
    ├── vpc/             # VPC, subnets, IGW, routes
    └── ec2/             # EC2 instance, AMI, user_data
```

---

## 🚀 How to Deploy

### Prerequisites
- AWS CLI configured (`aws configure`)
- Terraform v1.0+ installed
- GitHub account

### Steps
```bash
# Clone the repo
git clone https://github.com/Sinon1310/aws-gitops-infra.git
cd aws-gitops-infra

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy
terraform apply

# Destroy when done
terraform destroy
```

---

## 🔄 GitOps Workflow
```
1. Make changes to .tf files
2. git add . && git commit -m "your change"
3. git push origin main
4. CodePipeline triggers automatically
5. Terraform applies changes to AWS
6. CloudTrail logs every action
```

---

## 💡 Skills Demonstrated

- Infrastructure as Code (Terraform)
- GitOps workflow
- AWS VPC networking
- CI/CD for infrastructure
- IAM least-privilege design
- Remote state management
- Audit & compliance (CloudTrail)
- Auto Scaling ready architecture

---

## 💰 Cost

~$0/month (AWS Free Tier)

---

## 👨‍💻 Built By

**Sinon Rodrigues** — Cloud / DevOps Engineering Portfolio  
[GitHub](https://github.com/Sinon1310)

---

> *"Infrastructure should be boring, automated, and auditable."*
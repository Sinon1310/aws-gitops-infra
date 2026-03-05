# AI Coding Agent Instructions for aws-gitops-infra

## Project Overview

This is a **GitOps-driven Terraform infrastructure project** that automatically deploys AWS resources via CI/CD pipeline. Every `git push` to `main` triggers AWS CodePipeline → CodeBuild → `terraform apply`.

**Live Environment**: `ap-south-1` (Mumbai) | Web server: http://13.201.33.104

---

## Architecture & Data Flow

```
Developer pushes code → GitHub (main branch)
    ↓
AWS CodePipeline (triggered via CodeStar connection)
    ↓
AWS CodeBuild (runs buildspec.yml)
    ↓
    1. Downloads Terraform 1.14.6
    2. terraform init (loads S3 backend state)
    3. terraform plan
    4. terraform apply -auto-approve
    ↓
Provisions/updates: VPC → EC2 → Security Groups
    ↓
CloudTrail logs all AWS API calls to S3
```

**Critical Detail**: The pipeline **manages itself** — CodePipeline/CodeBuild resources are defined in Terraform and deployed by the same pipeline (bootstrap paradox handled via manual first deploy).

---

## Key Conventions & Patterns

### 1. **Modular Structure**
- Root configs: `main.tf`, `variables.tf`, `outputs.tf`, `backend.tf`
- Reusable modules: `modules/vpc/` and `modules/ec2/`
- Pipeline configs: `codepipeline.tf`, `codebuild.tf`, `iam.tf`, `cloudtrail.tf`

### 2. **Naming Convention**
All resources follow: `${var.project_name}-<resource-type>-<optional-suffix>`
- Example: `aws-gitops-infra-pipeline`, `aws-gitops-infra-build`, `aws-gitops-infra-vpc`

### 3. **Tagging Strategy**
Every resource MUST have:
```hcl
tags = {
  Name        = "${var.project_name}-<resource>"
  Environment = var.environment  # default: "dev"
}
```

### 4. **IAM Permissions Pattern**
- CodeBuild role needs wildcard permissions (`ec2:*`, `vpc:*`, `iam:*`, `codepipeline:*`) because it manages infrastructure
- CodePipeline role needs: `s3:*`, `codebuild:*`, `codestar-connections:UseConnection`
- **Never remove `codepipeline:*` from CodeBuild role** — causes self-referencing permission errors

### 5. **State Management**
- Backend: S3 bucket `sinon-terraform-state-2025` + DynamoDB `terraform-state-lock`
- State path: `aws-gitops-infra/terraform.tfstate`
- **Never run `terraform init -reconfigure` without backup** — state is critical

---

## Critical Workflows

### Deploy Changes
```bash
# Make changes to .tf files
git add .
git commit -m "feat: add new resource"
git push origin main
# Pipeline auto-triggers in ~30 seconds
```

### Manual Terraform (for debugging only)
```bash
terraform init
terraform plan
terraform apply        # Only if pipeline is broken
```

### Fix Pipeline Failures
1. Check CodeBuild logs: AWS Console → CodeBuild → `aws-gitops-infra-build` → Latest build
2. Look for `terraform plan` errors (usually IAM permissions or resource conflicts)
3. Common fixes:
   - IAM: Add missing permissions to `iam.tf` → CodeBuild role
   - State lock: Delete lock in DynamoDB `terraform-state-lock` table
   - Resource exists: Import with `terraform import <resource> <id>`

### Access EC2 Instance
```bash
# Get instance IP from outputs
terraform output ec2_public_ip

# SSH (if key configured)
ssh -i <key.pem> ec2-user@$(terraform output -raw ec2_public_ip)

# Test web server
curl http://$(terraform output -raw ec2_public_ip)
```

---

## File-Specific Guidance

### `buildspec.yml`
- Runs inside CodeBuild container (Amazon Linux 2)
- Downloads Terraform binary (not pre-installed)
- `terraform apply -auto-approve` runs unattended (no manual confirmation)
- **Never add interactive prompts here**

### `backend.tf`
- S3 bucket must exist BEFORE first `terraform init`
- DynamoDB table schema: Primary key = `LockID` (string)
- Change backend config → requires `terraform init -migrate-state`

### `modules/vpc/main.tf`
- Creates single public subnet (10.0.1.0/24) in `${var.aws_region}a`
- No private subnets yet (future enhancement)
- Security group allows ports 22 (SSH) and 80 (HTTP)

### `modules/ec2/main.tf`
- Uses latest Amazon Linux 2 AMI (via data source)
- Runs Apache via `user_data` script on first boot
- Instance type: `t3.micro` (Free Tier eligible)
- **Changing `user_data` does NOT recreate instance** — requires manual `terraform taint`

### `iam.tf`
- CodeBuild role has broad permissions by design (manages all infra)
- **Critical**: Must include `codepipeline:*` to avoid circular dependency errors

---

## Common Pitfalls

### ❌ IAM Permission Errors
**Symptom**: `terraform plan` fails with `AccessDeniedException`
**Fix**: Add missing service to CodeBuild role in `iam.tf` (e.g., `"autoscaling:*"`)

### ❌ State Lock Timeout
**Symptom**: `Error acquiring state lock` (previous build crashed)
**Fix**: Delete stuck lock in DynamoDB console → `terraform-state-lock` table

### ❌ Resource Already Exists
**Symptom**: `Error creating <resource>: AlreadyExists`
**Fix**: Import existing resource: `terraform import aws_vpc.main vpc-xxxxx`

### ❌ Pipeline Self-Reference Loop
**Symptom**: CodeBuild fails reading own CodePipeline resource
**Fix**: Ensure CodeBuild IAM role has `codepipeline:GetPipeline` permission

---

## Extending This Project

### To Add Auto Scaling Group + ALB:
1. Create `modules/asg/main.tf` + `modules/alb/main.tf`
2. Add outputs for ALB DNS name
3. Update security groups for ALB → EC2 traffic
4. Add `autoscaling:*` and `elasticloadbalancing:*` to CodeBuild IAM role

### To Add Private Subnets:
1. Add `aws_subnet.private` in `modules/vpc/main.tf`
2. Create NAT Gateway (costs ~$0.045/hour, not Free Tier)
3. Add private route table pointing to NAT

### To Add AWS Config (drift detection):
1. Create `config.tf` with `aws_config_configuration_recorder`
2. Define rules: `aws_config_config_rule` (e.g., detect manual changes)
3. Store config logs in S3

---

## Testing Strategy

**No automated tests yet** — this is IaC, not application code.

Manual verification:
```bash
# Test pipeline trigger
git commit --allow-empty -m "test: trigger pipeline"
git push origin main

# Verify infrastructure
terraform output
curl http://$(terraform output -raw ec2_public_ip)
```

---

## Reference Links

- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- CodeBuild buildspec: https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html
- CloudTrail events: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-events.html

---

**When in doubt**: Check AWS Console CodeBuild logs first — they show exact Terraform errors.

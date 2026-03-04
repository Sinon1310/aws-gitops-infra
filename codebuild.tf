# S3 bucket for CodePipeline artifacts
resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket        = "${var.project_name}-pipeline-artifacts-2025"
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-artifacts"
    Environment = var.environment
  }
}

# CodeBuild Project
resource "aws_codebuild_project" "terraform_build" {
  name          = "${var.project_name}-build"
  description   = "Runs terraform plan and apply"
  build_timeout = 10
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_VERSION"
      value = "1.14.6"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec.yml")
  }

  tags = {
    Name        = "${var.project_name}-build"
    Environment = var.environment
  }
}
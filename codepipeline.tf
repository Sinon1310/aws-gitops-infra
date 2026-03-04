# CodePipeline
resource "aws_codepipeline" "terraform_pipeline" {
  name     = "${var.project_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = "arn:aws:codestar-connections:ap-south-1:768289994925:connection/81fb4273-1c22-42c9-b09e-65a37d589d5f"
        FullRepositoryId = "Sinon1310/aws-gitops-infra"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Terraform_Apply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.terraform_build.name
      }
    }
  }

  tags = {
    Name        = "${var.project_name}-pipeline"
    Environment = var.environment
  }
}
# Resource for creating ec2 instance
resource "aws_instance" "cicd-server" {
  ami           = "ami-0b5eea76982371e91"
  instance_type = "t3.small"
  tags = {
    Name = "my-cicd-instance"
  }
}
#Resource for aws codestar source connection
resource "aws_codestarconnections_connection" "my-cicd-connection" {
  name          = "my-cicd-connection"
  provider_type = "GitHub" 
}
#Resource for creating s3 bucket
resource "aws_s3_bucket" "code_bucket" {
  bucket = "my-cicd-terraform-project-bucket"
}
#Resource for creating aws codepipeline
resource "aws_codepipeline" "codePipeline" {
  name     = "my-pipeline"
  role_arn = aws_iam_role.pipeline_role.arn
#Resource for creating artifact store
  artifact_store {
    location = aws_s3_bucket.code_bucket.bucket
    type     = "S3"
  }
#staging area for source , build , deploy
  stage {
    name = "Source"  
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      run_order        = "1"
      output_artifacts = ["source-artifacts"]
      configuration = {  
      connectionArn     = "aws_codestarconnections_connection.my-cicd-connection.arn"
      FullRepositoryId  = "var.FullRepositoryId"
      BranchName        = "var.Branch"
      }
    }
  }
  
  stage {
    name = "Build"
    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = 1
      input_artifacts = ["source_artifacts"]
      configuration = {
        ProjectName = "my-cicd-codebuild-project"
      }
    }
  }
  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "EC2"
      version         = 1
      input_artifacts = ["build_artifacts"]
      configuration = {
        InstanceName = "my-cicd-instance"
        DeploymentGroupName = "my-codedeploy-group"
      }
    }
  }
}
resource "aws_iam_role" "pipeline_role" {
  name = "codepipeline_example_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
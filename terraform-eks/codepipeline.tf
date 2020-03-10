resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "httpd-testing-artifacts-bucket"
  # acl    = "private"
}

data "template_file" "codepipeline_assume_role_policy" {
  template = file("${path.module}/files/iam_resources/codepipeline_assume_role.json")
}

resource "aws_iam_role" "codepipeline_assume_role" {
  name               = "CodePipelineServiceRole-new"
  assume_role_policy = data.template_file.codepipeline_assume_role_policy.rendered
}

data "template_file" "codepipeline_policy" {
  template = file("${path.module}/files/iam_resources/CodePipelineServiceRole.json")
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "CodePipelineServiceRole-new-policy"
  role   = aws_iam_role.codepipeline_assume_role.id
  policy = data.template_file.codepipeline_policy.rendered
}


resource "aws_codepipeline" "codepipeline" {
  name     = "httpd-testing"
  role_arn = "${aws_iam_role.codepipeline_assume_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.codepipeline_bucket.bucket}"
    type     = "S3"

    # encryption_key {
    #   id   = "${data.aws_kms_alias.s3kmskey.arn}"
    #   type = "KMS"
    # }
  }
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = "httpd-test"
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build_project.name
      }
    }
  }
}

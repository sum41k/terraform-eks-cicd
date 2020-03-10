#We need to attach this policy AmazonEC2ContainerRegistryPowerUser () to arn:aws:iam::600377393768:role/CodeBuildServiceRole

# CodeBuild IAM Permissions
data "template_file" "codebuild_assume_role_policy" {
  template = file("${path.module}/files/iam_resources/codebuild_assume_role.json")
}

resource "aws_iam_role" "codebuild_assume_role" {
  name               = "CodeBuildServiceRole-new"
  assume_role_policy = data.template_file.codebuild_assume_role_policy.rendered
}


data "template_file" "codebuild_policy" {
  template = file("${path.module}/files/iam_resources/CodeBuildServiceRole.json")
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "CodeBuildServiceRole-new-policy"
  role   = aws_iam_role.codebuild_assume_role.id
  policy = data.template_file.codebuild_policy.rendered
}

resource "aws_iam_role_policy_attachment" "ecr-attach" {
  role       = "${aws_iam_role.codebuild_assume_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# resource "aws_iam_role_policy_attachment" "eks-attach" {
#   role       = "${aws_iam_role.codebuild_assume_role.name}"
#   policy_arn = module.eks.cluster_iam_role_arn
# }


# resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = "${aws_iam_role.codebuild_assume_role.name}"
# }
#
# resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
#   role       = "${aws_iam_role.codebuild_assume_role.name}"
# }

# CodeBuild Section
resource "aws_codebuild_project" "build_project" {
  name         = "${var.repo_name}-package"
  description  = "The CodeBuild project for ${var.repo_name}"
  service_role = aws_iam_role.codebuild_assume_role.arn
  # build_timeout  = var.build_timeout
  # encryption_key = aws_kms_key.artifact_encryption_key.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:3.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = module.eks.cluster_id
    }
    environment_variable {
      name  = "EKS_CLUSTER_ARN"
      value = module.eks.cluster_arn
    }
    # environment_variable {
    #   name  = "HELM_S3_MODE"
    #   value = "2"
    # }
    environment_variable {
      name  = "EKS_CLUSTER_ROLE_ARN"
      value = aws_iam_role.codebuild_assume_role.arn
    }
    # cluster_iam_role_arn
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

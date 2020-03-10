variable "candidate" {
  default = "vlad-senko"
}

variable "environment" {
  default = "test"
}

variable "region" {
  default = "eu-west-1"
}

variable "name" {
  default = "candidate-test"
}

variable "platform_name" {
  default = "test"
}
#EKS variables

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::600377393768:user/terraform_new"
      username = "terraform_new"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::600377393768:user/cdk-workshop"
      username = "cdk-workshop"
      groups   = ["system:masters"]
    }
  ]
}
variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = [
    {
      rolearn  = "arn:aws:iam::600377393768:role/CodeBuildServiceRole-new"
      username = "build"
      groups   = ["system:masters"]
    }
  ]
}

# arn:aws:iam::600377393768:role/CodeBuildServiceRole-new
# ROLE="    - rolearn: arn:aws:iam::44755xxxxxxx:role/EksCodeBuildkubectlRole\n      username: build\n      groups:\n        - system:masters"
# variable "platform_name" {}

variable "create_external_zone" {
  description = "Boolean variable which defines whether external zone will be created or existing will be used"
  default     = true
}

variable "platform_external_subdomain" {
  description = "The name of existing or to be created(depends on create_external_zone variable) external DNS zone"
  default     = "sum41k-test.com"
}

# variable "platform_alb_dns_name" {}

variable "repo_name" {
  default = "httpd-test"
}

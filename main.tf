terraform {
  required_version = ">= 1.0"

  # TODO required providers
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_subnet" "this" {
  id = var.subnet_ids[0]
}

resource "aws_kms_key" "eks_cloudwatch_logs" {
  description             = "KMS key for Cloudwatch logs from ${local.cluster_name}"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-policy"
    Statement = [
      {
        Sid    = "Allow CloudWatch to encrypt and decrypt logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
        Condition : {
          "ArnEquals" : {
            "kms:EncryptionContext:aws:logs:arn" : "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/eks/${local.cluster_name}/cluster"
          }
        }
      },
      {
        Sid    = "Allow administration of the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}

module "vpc_cni_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name_prefix      = "VPC-CNI-IRSA"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv6   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}

resource "aws_kms_alias" "eks_cloudwatch" {
  name          = "alias/${local.prefix}-eks-${local.cluster_name}"
  target_key_id = aws_kms_key.eks_cloudwatch_logs.key_id
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  subnet_ids = var.subnet_ids
  vpc_id     = data.aws_subnet.this.vpc_id

  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  cluster_enabled_log_types              = var.cluster_enabled_log_types
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_kms_key_id        = aws_kms_key.eks_cloudwatch_logs.arn

  eks_managed_node_group_defaults = var.eks_managed_node_group_defaults
  eks_managed_node_groups         = var.eks_managed_node_groups

  //workers_additional_policies                        = [aws_iam_policy.ebs.arn]
  node_security_group_additional_rules = var.node_security_group_additional_rules

  # TODO openid_connect_audiences ??
  manage_aws_auth_configmap = var.manage_aws_auth_configmap
  aws_auth_roles            = var.aws_auth_roles
  aws_auth_users            = var.aws_auth_users
}

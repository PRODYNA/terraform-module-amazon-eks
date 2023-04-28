module "eks_cluster_autoscaler" {
  source  = "lablabs/eks-cluster-autoscaler/aws"
  version = ">= 2.1.0"

  enabled           = var.deploy_cluster_autoscaler
  argo_enabled      = false
  argo_helm_enabled = false

  cluster_name                     = module.eks.cluster_name
  cluster_identity_oidc_issuer     = module.eks.oidc_provider
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
}
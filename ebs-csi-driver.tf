module "eks-ebs-csi-driver" {
  source  = "lablabs/eks-ebs-csi-driver/aws"
  version = ">= 0.1.0"

  enabled           = var.deploy_ebs_csi_driver
  argo_enabled      = false
  argo_helm_enabled = false

  cluster_identity_oidc_issuer     = module.eks.oidc_provider
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
}
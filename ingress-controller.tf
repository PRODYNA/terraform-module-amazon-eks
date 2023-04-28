/*
module "load_balancer_controller" {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-lb-controller.git"

  cluster_identity_oidc_issuer     = module.eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
  cluster_name                     = module.eks.cluster_id

  settings = {
    replicaCount = 1
  }
}
*/


module "lb_controller" {
  source  = "lablabs/eks-load-balancer-controller/aws"
  version = ">= 1.2.0"

  enabled           = var.deploy_loadbalancer_controller
  argo_enabled      = false
  argo_helm_enabled = false

  cluster_name                     = module.eks.cluster_name
  cluster_identity_oidc_issuer     = module.eks.oidc_provider
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
}
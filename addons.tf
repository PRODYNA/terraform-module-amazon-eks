# TODO EBS CSI driver with GP3
#tfsec:ignore:aws-iam-no-policy-wildcards
module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons"

  eks_cluster_id = module.eks.cluster_name

  # EKS Addons
  enable_amazon_eks_aws_ebs_csi_driver = lookup(var.cluster_addons, "enable_amazon_eks_aws_ebs_csi_driver", true)
  enable_amazon_eks_coredns            = false
  enable_amazon_eks_kube_proxy         = false
  enable_amazon_eks_vpc_cni            = false

  #K8s Add-ons
  enable_aws_load_balancer_controller      = lookup(var.cluster_addons, "enable_aws_load_balancer_controller", true)
  aws_load_balancer_controller_helm_config = var.aws_load_balancer_controller_helm_config
  enable_cluster_autoscaler                = lookup(var.cluster_addons, "enable_cluster_autoscaler", true)
  cluster_autoscaler_helm_config           = var.cluster_autoscaler_helm_config
  enable_metrics_server                    = lookup(var.cluster_addons, "enable_metrics_server", true)
  metrics_server_helm_config               = var.metrics_server_helm_config
  enable_external_dns                      = lookup(var.cluster_addons, "enable_external_dns", true)
  external_dns_route53_zone_arns           = var.external_dns_route53_zone_arns
  eks_cluster_domain                       = var.eks_cluster_domain
}
#tfsec:ignore:aws-iam-no-policy-wildcards
module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons"

  eks_cluster_id = module.eks.cluster_name

  # EKS Addons
  enable_amazon_eks_aws_ebs_csi_driver = lookup(var.cluster_addons, "enable_amazon_eks_aws_ebs_csi_driver", true)
  amazon_eks_aws_ebs_csi_driver_config = lookup(var.cluster_addon_configs, "amazon_eks_aws_ebs_csi_driver_config", {})
  enable_amazon_eks_coredns            = lookup(var.cluster_addons, "enable_amazon_eks_coredns", true)
  amazon_eks_coredns_config            = lookup(var.cluster_addon_configs, "amazon_eks_coredns_config", {})
  enable_amazon_eks_kube_proxy         = lookup(var.cluster_addons, "enable_amazon_eks_kube_proxy", true)
  amazon_eks_kube_proxy_config         = lookup(var.cluster_addon_configs, "amazon_eks_kube_proxy_config", {})
  enable_amazon_eks_vpc_cni            = lookup(var.cluster_addons, "enable_amazon_eks_vpc_cni", true)
  amazon_eks_vpc_cni_config            = lookup(var.cluster_addon_configs, "amazon_eks_vpc_cni_config", {})

  #K8s Add-ons
  enable_aws_load_balancer_controller      = lookup(var.cluster_addons, "enable_aws_load_balancer_controller", true)
  aws_load_balancer_controller_helm_config = lookup(var.cluster_addon_configs, "aws_load_balancer_controller_helm_config", {})
  enable_cluster_autoscaler                = lookup(var.cluster_addons, "enable_cluster_autoscaler", true)
  cluster_autoscaler_helm_config           = lookup(var.cluster_addon_configs, "cluster_autoscaler_helm_config", {})
  enable_metrics_server                    = lookup(var.cluster_addons, "enable_metrics_server", true)
  metrics_server_helm_config               = lookup(var.cluster_addon_configs, "metrics_server_helm_config", {})
  enable_external_dns                      = local.enable_external_dns
  external_dns_route53_zone_arns           = var.external_dns_route53_zone_arns
  eks_cluster_domain                       = var.eks_cluster_domain
}

#######
# Storage classes
#######

resource "kubernetes_annotations" "gp2" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  force       = "true"

  metadata {
    name = "gp2"
  }

  annotations = {
    # Modify annotations to remove gp2 as default storage class still reatain the class
    "storageclass.kubernetes.io/is-default-class" = "false"
  }

  depends_on = [
    module.eks_blueprints_kubernetes_addons
  ]
}

resource "kubernetes_storage_class_v1" "gp3" {
  metadata {
    name = "gp3"

    annotations = {
      # Annotation to set gp3 as default storage class
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  allow_volume_expansion = true
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"

  parameters = {
    encrypted = true
    fsType    = "ext4"
    type      = "gp3"
  }

  depends_on = [
    module.eks_blueprints_kubernetes_addons
  ]
}

#######
# HTTPS with external DNS
#######

resource "aws_acm_certificate" "this" {
  count = local.enable_external_dns ? 1 : 0

  domain_name       = var.eks_cluster_domain
  validation_method = "DNS"
}


resource "aws_route53_record" "this" {
  for_each = local.enable_external_dns && aws_acm_certificate.this != null ? {
    for dvo in aws_acm_certificate.this[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  name    = each.value.name
  type    = each.value.type
  zone_id = var.external_dns_route53_zone_id
  records = [each.value.record]
  ttl     = "60"
}

resource "aws_acm_certificate_validation" "this" {
  count = local.enable_external_dns ? 1 : 0

  certificate_arn         = aws_acm_certificate.this[0].arn
  validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]
}

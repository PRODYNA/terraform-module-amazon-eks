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

resource "aws_acm_certificate" "this" {
  count = var.cluster_addons.enable_external_dns ? 1 : 0

  domain_name       = var.eks_cluster_domain
  validation_method = "DNS"
}

resource "aws_route53_record" "this" {
  for_each = {
    for dvo in aws_acm_certificate.this[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  type    = each.value.type
  zone_id = var.external_dns_route53_zone_id
  records = [each.value.record]
  ttl     = "60"
}

resource "aws_acm_certificate_validation" "this" {
  count = var.cluster_addons.enable_external_dns ? 1 : 0

  certificate_arn         = aws_acm_certificate.this[0].arn
  validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]
}

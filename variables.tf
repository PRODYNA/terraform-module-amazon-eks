variable "environment" {
  description = "The name of the stage."
  type        = string
}

variable "project" {
  description = "Project name."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets"
  type        = list(string)
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.24`)"
  type        = string
}

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node group definitions to create. https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/eks-managed-node-group"
  type        = any
}

variable "eks_managed_node_group_defaults" {
  description = "Map of EKS managed node group default configurations"
  type        = any
}

variable "manage_aws_auth_configmap" {
  description = "Determines whether to manage the aws-auth configmap"
  type        = bool
  default     = true
}

variable "aws_auth_roles" {
  description = "List of role maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}

variable "aws_auth_users" {
  description = "List of user maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}

variable "node_security_group_additional_rules" {
  description = "List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source"
  type        = any
  default     = {}
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days"
  type        = number
  default     = 90
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "use_case" {
  description = "The use case of the Kubernetes cluster. Used in in the cluster name."
  type        = string
  default     = "k8s"
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
  default     = ["api", "authenticator", "audit", "scheduler", "controllerManager"]
}

variable "cluster_addons" {
  description = "EKS and K8s addons to enable."
  type        = map(bool)
  default = {
    enable_amazon_eks_aws_ebs_csi_driver = true
    enable_amazon_eks_coredns            = true
    enable_amazon_eks_kube_proxy         = true
    enable_amazon_eks_vpc_cni            = true

    enable_aws_load_balancer_controller = true
    enable_cluster_autoscaler           = true
    enable_metrics_server               = true
    enable_external_dns                 = true
  }
}

variable "cluster_addon_configs" {
  description = "Configurations for the EKS and K8s addons (see 'cluster_addons')"
  type        = map(any)
  default = {
    amazon_eks_aws_ebs_csi_driver_config = {}
    amazon_eks_coredns_config            = {}
    amazon_eks_kube_proxy_config         = {}
    amazon_eks_vpc_cni_config            = {}

    aws_load_balancer_controller_helm_config = {}
    cluster_autoscaler_helm_config           = {}
    metrics_server_helm_config               = {}
    external_dns_helm_config                 = {}
  }
}

variable "external_dns_helm_config" {
  description = "External DNS Helm Chart config"
  type        = any
  default     = {}
}

variable "external_dns_route53_zone_arns" {
  description = "List of Route53 zones ARNs which external-dns will have access to create/manage records"
  type        = list(string)
  default     = []
}

variable "external_dns_route53_zone_id" {
  description = "Route53 zone id for the hosted zone used to for the EKS cluster."
  type        = string
  default     = null
}

variable "eks_cluster_domain" {
  description = "The domain for the EKS cluster"
  type        = string
  default     = ""
}

locals {
  cluster_name        = "${local.prefix}-${var.use_case}"
  prefix_env          = terraform.workspace == "default" ? var.environment : terraform.workspace
  prefix              = "${var.project}-${local.prefix_env}"
  enable_external_dns = lookup(var.cluster_addons, "enable_external_dns", true) && var.eks_cluster_domain != "" && length(var.external_dns_route53_zone_arns) > 0 && var.external_dns_route53_zone_id != null
}

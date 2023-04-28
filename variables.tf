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
  default     = ["audit", "api", "authenticator"]
}

variable "cluster_addons" {
  description = "Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name`"
  type        = any
  default     = {}
}

variable "deploy_loadbalancer_controller" {
  description = "Deploy the aws-load-balancer-controller. https://github.com/kubernetes-sigs/aws-load-balancer-controller"
  type        = bool
  default     = true
}

variable "deploy_ebs_csi_driver" {
  description = "Deploy the EBS CSI driver to auto. provision EBS drives for PVC's. https://github.com/lablabs/terraform-aws-eks-ebs-csi-driver"
  type        = bool
  default     = true
}

locals {
  cluster_name = "${local.prefix}-${var.use_case}"
  prefix_env   = terraform.workspace == "default" ? var.environment : terraform.workspace
  prefix       = "${var.project}-${local.prefix_env}"
}

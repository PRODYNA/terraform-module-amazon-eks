output "cluster_name" {
  description = "Name of EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  description = "Certificate authority data of the EKS cluster."
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "eks_managed_node_groups" {
  description = "Outputs from node groups"
  value       = module.eks.eks_managed_node_groups
}

output "aws_auth_configmap_yaml" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = module.eks.aws_auth_configmap_yaml
}

output "cluster_certificate_arn" {
  description = "ARN of the cluster ACM certificate used for TLS."
  value       = join("", aws_acm_certificate.this.*.arn)
}

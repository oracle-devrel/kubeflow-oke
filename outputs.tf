output "cluster_id" {
  description = "ID of the Kubernetes cluster"
  value       = module.oke.cluster_id
}
output "vcn_id" {
  description = "id of vcn where oke is created. use this vcn id to add additional resources"
  value       = module.oke.vcn_id
}
output "subnet_ids" {
  description = "map of subnet ids (worker, int_lb, pub_lb) used by OKE."
  value       = module.oke.subnet_ids
}
output "kubeconfig" {
  description = "convenient command to set KUBECONFIG environment variable before running kubectl locally"
  value       = "export KUBECONFIG=generated/kubeconfig"
}
output "nsg_ids" {
  description = "map of NSG ids (cp, worker, int_lb, pub_lb, pod) used by OKE."
  value       = module.oke.nsg_ids
}
output "cluster_endpoints" {
  description = "Endpoints for the Kubernetes cluster"
  value       = module.oke.cluster_endpoints
}

output "autoscaling_nodepools" {
  description = "Auto scaling node pools info"
  value = module.oke.autoscaling_nodepools
}

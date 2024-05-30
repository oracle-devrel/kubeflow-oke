# Copyright 2017, 2023 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Provider configurations for resource + home regions w/ some automatically derived values

# tflint-ignore: terraform_required_providers
provider "oci" {
  #config_file_profile  = var.config_file_profile
  fingerprint          = var.api_fingerprint
  private_key_path     = var.api_private_key_path
  #private_key_password = var.api_private_key_password
  region               = var.region
  tenancy_ocid         = var.tenancy_id
  user_ocid            = var.user_id
}

# tflint-ignore: terraform_required_providers
provider "oci" {
  alias                = "home"
  #config_file_profile  = var.config_file_profile
  fingerprint          = var.api_fingerprint
  private_key_path     = var.api_private_key_path
  #private_key_password = var.api_private_key_password
  region               = var.home_region
  tenancy_ocid         = var.tenancy_id
  user_ocid            = var.user_id
}

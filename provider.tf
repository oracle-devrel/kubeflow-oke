provider "oci" {
   auth = "InstancePrincipal"
   region = "us-ashburn-1"
}
provider "oci" {
   auth = "InstancePrincipal"
   region = "us-ashburn-1"
   alias  = "home"
}

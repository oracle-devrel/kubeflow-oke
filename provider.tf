provider "oci" {
   auth = "InstancePrincipal"
   # Change this to be the region you want to deploy into
   region = "us-ashburn-1"
}
provider "oci" {
   auth = "InstancePrincipal"
   # change this to be your home region
   region = "us-ashburn-1"
   alias  = "home"
}

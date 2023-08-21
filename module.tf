module oke {

  # the location of the oke terraform module and the version to use
  source  = "oracle-terraform-modules/oke/oci"
  version = "4.5.9"
  # this needs to be the OCID to create the cluster in
  compartment_id=""
  # this is the OCID of the tenancy in the OCI cloud shell get this using echo $OCI_TENNANCY
  tenancy_id=""
  # The home region of your tenncy - needed to congigure policies, groups and the like
  home_region="eu-frankfurt-1"
  # The region you want to create the cluster in
  region="uk-london-1"
  # the name to give the cluster and will also be used in it's associated resources
  cluster_name="kubeflow1"

  # the name of the VCN to create
  vcn_name="oke-vcn-kubeflow"
  # the address range of the VCN
  vcn_cidrs=["10.0.0.0/16"]

  # this is creating a simple cluser, in a production ewnvironment you'll probabaly want better security.
  # Look at the OCI terraform module documentation at https://github.com/oracle-terraform-modules/terraform-oci-oke (chose the branch that batches the version you're using)

  create_bastion_host=false
  create_bastion_service=false
  create_operator=false

  # allow the kubernetes control plan to be accessed from anywhere on the internet (assuming you've got the appropriate security credentials of course !)
  control_plane_type="public"
  control_plane_allowed_cidrs=["0.0.0.0/0"]

  # what version of kubernetes to instal, not all kubernrtes versions are supported so check in the OCI UI
  kubernetes_version="v1.26.2"

  # The below is a 3 node pool setup, assuming that you have the mechanisms in kubeflow to setup affinity to target workloads to specific pools / processing types
  node_pools = {
    # this is a node pool for running system processes in, e.g. prometheus and metrics server
    system = { shape = "VM.Standard.E4.Flex", ocpus = 1, memory = 16, node_pool_size = 3, boot_volume_size = 50, label = {apptype = "system", pool = "system" } }, 
    # this is a node pool for running actuall applications in, e.g. the kubeflow runtime
    app = { shape = "VM.Standard.E4.Flex", ocpus = 2, memory = 32, node_pool_size = 3, boot_volume_size = 100, label = {apptype = "app", pool = "app" } }, 
    # this is a node pool for executing your actual analysis in, if you want this to auto scale set autoscale to be true and the max_node_pool_size to meet your needs
    # NOTE see below for requirements around autoscaling as there are other things you need to do
    procesing = { shape = "VM.Standard.E4.Flex", ocpus = 4, memory = 64, node_pool_size = 1, max_node_pool_size = 5, boot_volume_size = 100, autoscale = false, label = {apptype = "processing", pool = "processing" }, }
  } 

  # the autostaler flag in the node pool means that the autoscaler will manage that node pool, however you need to set this flag
  # to true to actually install the autoscaler, that will create an additional node pool to run the auto scaler (thus enturing it wont't sale itself out of existence)
  # If you are using the autoscaler it is ctitical that you fololow the instructions here https://github.com/oracle-terraform-modules/terraform-oci-oke/blob/main/docs/clusterautoscaler.adoc
  # as you need to setup some additional dynamic groups and policies for it to install and work properly
  enable_cluster_autoscaler = false
  autoscaler_pools = {
    # the auto scaler is kubernetes release specific. To allow for upgrades the oke tf will create
    # a node pool (single node)to run it. the node pool will be specific to each kubernrtes version so you can upgrade
    # clusters having different kubernrtes versions in different node pools. Hence advisable to name
    # ther nodepool with the kubernrtes version to help you understand what's happening where
    # only 1 pool is needed at a time unless during upgrade
    asp_v126 = {}
  }

  # install the modified cloud init, this will setup the kernel moduled needed by istio and also arrange for them to be installed if the node reboots
  cloudinit_nodepool_common = "./cloud-init.sh"
  # metrics server is generally usefull
  enable_metric_server = true
  # tells terrafcorm how to talk to OCI
  providers = {
    oci.home = oci.home
  }
}

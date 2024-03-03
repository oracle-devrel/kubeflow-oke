# Kubeflow on Oracle Container Engine for Kubernetes

[uri-Kubernetes]: https://Kubernetes.io/
[uri-oci]: https://cloud.oracle.com/cloud-infrastructure
[uri-oracle]: https://www.oracle.com

[![License: UPL](https://img.shields.io/badge/license-UPL-green)](https://img.shields.io/badge/license-UPL-green) [![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=oracle-devrel_kubeflow-oke)](https://sonarcloud.io/dashboard?id=oracle-devrel_kubeflow-oke)

## Introduction

Oracle Container Engine for Kubernetes (OKE) is the [Oracle][uri-oracle]-managed [Kubernetes][uri-Kubernetes] service on [Oracle Cloud Infrastructure (OCI)][uri-oci].

## Getting Started

> ⚠️ Kubeflow 1.5.0 is not compatible with Kubernetes version 1.22 and onwards. To install Kubeflow 1.5.0 or older, set the Kubernetes version of your OKE cluster to v1.21.5.

> ⚠️ This guide explains how to install Kubeflow 1.8.0 on OKE using Kubernetes versions 1.28.2 and onwards running on Oracle Linux 8.

> Note the following steps are for testing purposes. 

<!-- ## Installation -->

<!-- This section describes how to create a Kubernetes cluster using OKE, access OKE, install Kubeflow and expose Kubeflow Dashboard. -->

### Prerequisites

This guide can be run in many different ways, but in all cases, you will need to be signed into an Oracle Cloud Infrastructure tenancy.

This guide uses the [Cloud Shell](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/devcloudshellintro.htm) built into the Oracle Cloud Console but can also be run from your local workstation.

### Create an OKE cluster

1. From the OCI Cloud Shell clone this repo.
git clone https://github.com/oracle-devrel/kubeflow-oke.git

1. Edit the module.tf file to set the compartment and tenancy ocid's, your home region and the region you want to deploy in review the other settings, especially the security settings around control plane access, bastions and operators. If needed change the Kubernetes version to match the version supported by the Kubeflow version you are installing. Consider the node pool setup and if you want to use the cluster autoscaler. 

    Review the number of nodes in each node pool, in this example we are using three node pools.
   - system for running system processes in, e.g. prometheus and metrics server.
   - app for running actuall applications in, e.g. the kubeflow runtime.
   - processing for executing your actual analysis in, if you want this to auto scale set autoscale to be true and the max_node_pool_size to meet your needs.

2. Edit the providers.tf file, replace the first provider region with the name of the region you want to create the OKE cluster in, replace the second provider region with the name of your home region (there are comments indicating which one to change to what).

If you are running in the OCI cloud shell (recommended), then you're all good to go. If not, you will need to configure the terraform provider security credentials

setup terraform with : 
```bash
terraform init
```

plan the deployment : 
```bash
terraform plan --out=kubeflow.plan
```

apply the deployment : 
```bash
terraform apply kubeflow.plan
```

Now you need to follow the OCI Kubernetes Environment instructions for getting your Kubernetes config information and adding it to your local kubeconfig.

To access your OKE cluster:
1. Click Access Cluster on the cluster detail page.
2. Accept the default Cloud Shell Access and click Copy to copy the oci ce cluster create-kubeconfig ... command.
3. Paste it into your Cloud Shell session and hit Enter.

![cluster1](images/AccessCluster.png)

  Verify that the `kubectl` is working by using the `get nodes` command. 
  
  Repeat this command several times until all three nodes show `Ready` in the `STATUS` column.

```bash
kubectl get nodes
NAME          STATUS   ROLES   AGE   VERSION
10.0.10.176   Ready    node    19m   v1.26.2
10.0.10.203   Ready    node    19m   v1.26.2
10.0.10.48    Ready    node    19m   v1.26.2
```

  When all three nodes are `Ready`, your OKE install has finished successfully.

## Install Kubeflow

Now the cluster is ready, run the install-kubeflow.sh script to 
set up the version of kustomise and the kubeflow branch to use.

```bash
./install-kubeflow.sh
```

The script output will provide you with the URL, login and password to access Kubeflow console.

`Your kubeflow dashboard is at https://x.x.x.x.nip.io
Login as user@example.com.`

`This is your kubeflow password for user user@example.com
xxxxxx`


To destroy, you must remove the non-Terraform constructed OCI resources, specifically the Istio gateway load balancer. The easiest way here is to remove the service.

```bash
kubectl delete service istio-ingressgateway  -n istio-system
```

## URLs

Kubeflow: <https://www.kubeflow.org/>

## Contributing

Oracle appreciates any contributions that are made by the community. Please submit your contributions by forking this repository and submitting a pull request. Opening an issue to discuss your contribution beforehand, especially if it's a new feature, would be appreciated.

## License

Copyright (c) 2024 Oracle and/or its affiliates.

Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://opensource.oracle.com/licenses/upl/

See [LICENSE](LICENSE) for more details.

ORACLE AND ITS AFFILIATES DO NOT PROVIDE ANY WARRANTY WHATSOEVER, EXPRESS OR IMPLIED, FOR ANY SOFTWARE, MATERIAL OR CONTENT OF ANY KIND CONTAINED OR PRODUCED WITHIN THIS REPOSITORY, AND IN PARTICULAR SPECIFICALLY DISCLAIM ANY AND ALL IMPLIED WARRANTIES OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A PARTICULAR PURPOSE. FURTHERMORE, ORACLE AND ITS AFFILIATES DO NOT REPRESENT THAT ANY CUSTOMARY SECURITY REVIEW HAS BEEN PERFORMED WITH RESPECT TO ANY SOFTWARE, MATERIAL OR CONTENT CONTAINED OR PRODUCED WITHIN THIS REPOSITORY. IN ADDITION, AND WITHOUT LIMITING THE FOREGOING, THIRD PARTIES MAY HAVE POSTED SOFTWARE, MATERIAL OR CONTENT TO THIS REPOSITORY WITHOUT ANY REVIEW. USE AT YOUR OWN RISK.

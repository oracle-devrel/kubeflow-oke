# Kubeflow on Oracle Container Engine for Kubernetes

[uri-Kubernetes]: https://Kubernetes.io/
[uri-oci]: https://cloud.oracle.com/cloud-infrastructure
[uri-oracle]: https://www.oracle.com

[![License: UPL](https://img.shields.io/badge/license-UPL-green)](https://img.shields.io/badge/license-UPL-green) [![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=oracle-devrel_kubeflow-oke)](https://sonarcloud.io/dashboard?id=oracle-devrel_kubeflow-oke)

## Introduction

Oracle Container Engine for Kubernetes (OKE) is the [Oracle][uri-oracle]-managed [Kubernetes][uri-Kubernetes] service on [Oracle Cloud Infrastructure (OCI)][uri-oci].

## Getting Started

[!IMPORTANT] ⚠️ Kubeflow 1.5.0 is not compatible with Kubernetes version 1.22 and onwards. To install Kubeflow 1.5.0 or older, set the Kubernetes version of your OKE cluster to v1.21.5.

This guide explains how to install Kubeflow 1.8.0 on OKE using Kubernetes versions 1.28.2 and onwards running on Oracle Linux 8.

### Prerequisites

This guide can be run in many different ways, but in all cases, you will need to be signed into an Oracle Cloud Infrastructure tenancy.

This guide uses the [Cloud Shell](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/devcloudshellintro.htm) built into the Oracle Cloud Console but can also be run from your local workstation.

## 1. Create an OKE cluster

This section describes how to:

- Create a Kubernetes cluster using OKE
- Accessing OKE
- Installing Kubeflow and how to expose the Kubeflow Dashboard

1. Launch an OCI Cloud Shell instance within your OCI tenancy. Once you're inside, let's clone this repository to get access to the resources available:

    ```bash
    git clone https://github.com/oracle-devrel/kubeflow-oke.git
    cd kubeflow-oke # get into the directory after cloning
    ```

2. Obtain the OCIDs we will need for the next step:

    ```bash
    echo $OCI_TENANCY
    echo $OCI_REGION
    echo $OCI_COMPARTMENT
    ```

3. Edit the `module.tf` file. We ned to set 4 variables: the compartment and tenancy OCIDs, your home region (see [all region identifiers here](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm)) and the region identifier where you want to deploy Kubeflow. From here, you can also review other settings, including security settings around control plane access, bastions and operators. If needed, change the Kubernetes version to match the version supported by the Kubeflow version you are installing. Consider the node pool setup and if you want to use the cluster autoscaler.

    Review the number of nodes in each node pool, in this example we are using three node pools.

    - **System** for running system processes, e.g. *Prometheus* server.
    - **App** for running actual applications, e.g. the kubeflow runtime.
    - **Processing** for executing your actual analysis in, if you want this to auto scale set `autoscale` to `True` and modify `max_node_pool_size` to meet your needs.

4. Edit the `provider.tf` file:

    - Replace the first provider region with the name of the region you want to create the OKE cluster in, replace the second provider region with the name of your home region (there are comments indicating which one to change to what).

5. If you aren't running this installation in your OCI Cloud Shell instance, you will need to configure  OCI's security credentials for Terraform:

    ```bash
    terraform init
    ```

6. Plan the deployment, and let's save the plan to a file:

    ```bash
    terraform plan --out=kubeflow.plan
    ```

7. Apply the deployment (run the script):

    ```bash
    terraform apply kubeflow.plan
    ```

Now you need to follow the OCI Kubernetes Environment instructions for getting your Kubernetes config information and adding it to your local kubeconfig.

To access your OKE cluster:

1. Click Access Cluster on the `Cluster details` page:

    ![cluster1](images/AccessCluster.png)

2. Accept the default Cloud Shell Access and click Copy to copy the oci ce cluster create-kubeconfig ... command.

3. To access the cluster, paste the command into your Cloud Shell session and hit Enter.

4. Verify that the `kubectl` is working by using the `get nodes` command.

5. Repeat this command multiple times until all three nodes show `Ready` in the `STATUS` column:

    ```bash
    $ kubectl get nodes
    NAME          STATUS   ROLES   AGE   VERSION
    10.0.10.176   Ready    node    19m   v1.26.2
    10.0.10.203   Ready    node    19m   v1.26.2
    10.0.10.48    Ready    node    19m   v1.26.2
    ```

    When all three nodes are `Ready`, your OKE installation has finished successfully.

## Install Kubeflow

Now that the cluster is ready, we can begin to install Kubeflow within the OKE cluster.

0. If you're running in a Compute Instance and not Cloud Shell, you will need to install `Kustomize`:

    ```bash
    
    ```

1. Let's run the `install-kubeflow.sh` script (found in this repository's) to set up the version of `kustomise` and specify which `kubeflow` branch to use:

    ```bash
    ./install-kubeflow.sh
    ```

2. The script output will provide you with the URL, login and password to access Kubeflow console.

3. Your kubeflow dashboard is at https://<IP_ADDRESS>. Login as `user@example.com`:

    ```bash
    This is your kubeflow password for user user@example.com:

    xxxxxx
    ```

4. (Optional) To destroy, you must remove the non-Terraform constructed OCI resources, specifically the Istio gateway load balancer. The easiest way here is to remove the service:

  ```bash
  kubectl delete service istio-ingressgateway  -n istio-system
  ```

## URLs

Kubeflow: https://www.kubeflow.org/

## Contributing

Oracle appreciates any contributions that are made by the community. Please submit your contributions by forking this repository and submitting a pull request. Opening an issue to discuss your contribution beforehand, especially if it's a new feature, would be appreciated.

## License

Copyright (c) 2024 Oracle and/or its affiliates.

Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://opensource.oracle.com/licenses/upl/

See [LICENSE](LICENSE) for more details.

ORACLE AND ITS AFFILIATES DO NOT PROVIDE ANY WARRANTY WHATSOEVER, EXPRESS OR IMPLIED, FOR ANY SOFTWARE, MATERIAL OR CONTENT OF ANY KIND CONTAINED OR PRODUCED WITHIN THIS REPOSITORY, AND IN PARTICULAR SPECIFICALLY DISCLAIM ANY AND ALL IMPLIED WARRANTIES OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A PARTICULAR PURPOSE. FURTHERMORE, ORACLE AND ITS AFFILIATES DO NOT REPRESENT THAT ANY CUSTOMARY SECURITY REVIEW HAS BEEN PERFORMED WITH RESPECT TO ANY SOFTWARE, MATERIAL OR CONTENT CONTAINED OR PRODUCED WITHIN THIS REPOSITORY. IN ADDITION, AND WITHOUT LIMITING THE FOREGOING, THIRD PARTIES MAY HAVE POSTED SOFTWARE, MATERIAL OR CONTENT TO THIS REPOSITORY WITHOUT ANY REVIEW. USE AT YOUR OWN RISK.

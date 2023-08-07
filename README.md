# Kubeflow on Oracle Container Engine for Kubernetes

[uri-kubernetes]: https://kubernetes.io/
[uri-oci]: https://cloud.oracle.com/cloud-infrastructure
[uri-oracle]: https://www.oracle.com

[![License: UPL](https://img.shields.io/badge/license-UPL-green)](https://img.shields.io/badge/license-UPL-green) [![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=oracle-devrel_kubeflow-oke)](https://sonarcloud.io/dashboard?id=oracle-devrel_kubeflow-oke)

## Introduction

Oracle Container Engine for Kubernetes (OKE) is the [Oracle][uri-oracle]-managed [Kubernetes][uri-kubernetes] service on [Oracle Cloud Infrastructure (OCI)][uri-oci].

## Getting Started

> ⚠️ Kubeflow 1.5.0 is not compatible with Kubernetes version 1.22 and onwards. To install Kubeflow 1.5.0 or older, set the Kubernetes version of your OKE cluster to v1.21.5.

This guide explains how to install Kubeflow 1.7.0 on OKE using Kubernetes versions 1.25.6 and onwards running on Oracle Linux 8.

<!-- ## Installation -->

<!-- This section describes how to create a Kubernetes cluster using OKE, access OKE, install Kubeflow and expose Kubeflow Dashboard. -->

### Prerequisites

This guide can be run in many different ways, but in all cases, you will need to be signed into an Oracle Cloud Infrastructure tenancy.

This guide uses the [Cloud Shell](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/devcloudshellintro.htm) built into the Oracle Cloud Console but can also be run from your local workstation.

### Create an OKE cluster

1. from the OCI Cloud Shell clone this repo.
git clone https://github.com/oracle-devrel/kubeflow-oke.git

1. edit the module.tf file to set the  compartment and tenancy ocid's, your home region and the region you want to deploy in review the other settings, especially the security settings around control plane access, bastions and operators
consider the ode pool setup and if you want to use the cluster autoscaler

if you are running in the OCI cloud shell (recommended) then you're all good to go, if not you will need to configure the terraform provider security credentials

setup terraform with : terraform init
plan the deployment : terraform plan --out=kubeflow.plan
apply the deployment : terraform apply kubeflow.plan

Now you need to follow the OCI Kubernrtes Environment instructins for getting your kubernetes config information and adding it to youre local kubeconfig

Do a kubectl get nodes to be sure that the cluster is accessible

## Install Kubeflow

Now you have the cluster look at the install-kubeflow.sh script
setup the version of kustomise and the kubeflow branch to use - for example for kubeflow 1.6 you'd need a branch called v1.6-branch but you need to ensure that the branch you're using is vaid for your cluster and kustomize version. This is because you may find that things in the kubernrtesd change (e.g. autoscaler moving fomr v2beta2 to v2 in kubernrtes 1.26 means that the 1.7 branch of kuberflow woudln't work and you had to use the latest updates to the master branch)


to destroy YOU MUST remove the none terraform constructed OCI resources, specifically the istio gateway load balancer. The easiest way here is to just remove the service with
kubectl delete service istio-ingressgateway  -n istio-system

Then make sure you've not doing anything with external persistence as that wil hang around once you kill off the cluster - and if on the VCN may prevent the VCN being destroyed
once that's gone then running terraform destroy should wipe out the cluster

## URLs

Kubeflow: <https://www.kubeflow.org/>

## Contributing

Oracle appreciates any contributions that are made by the community. Please submit your contributions by forking this repository and submitting a pull request. Opening an issue to discuss your contribution beforehand, especially if it's a new feature, would be appreciated.

## License

Copyright (c) 2022 Oracle and/or its affiliates.

Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://opensource.oracle.com/licenses/upl/

See [LICENSE](LICENSE) for more details.

ORACLE AND ITS AFFILIATES DO NOT PROVIDE ANY WARRANTY WHATSOEVER, EXPRESS OR IMPLIED, FOR ANY SOFTWARE, MATERIAL OR CONTENT OF ANY KIND CONTAINED OR PRODUCED WITHIN THIS REPOSITORY, AND IN PARTICULAR SPECIFICALLY DISCLAIM ANY AND ALL IMPLIED WARRANTIES OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A PARTICULAR PURPOSE. FURTHERMORE, ORACLE AND ITS AFFILIATES DO NOT REPRESENT THAT ANY CUSTOMARY SECURITY REVIEW HAS BEEN PERFORMED WITH RESPECT TO ANY SOFTWARE, MATERIAL OR CONTENT CONTAINED OR PRODUCED WITHIN THIS REPOSITORY. IN ADDITION, AND WITHOUT LIMITING THE FOREGOING, THIRD PARTIES MAY HAVE POSTED SOFTWARE, MATERIAL OR CONTENT TO THIS REPOSITORY WITHOUT ANY REVIEW. USE AT YOUR OWN RISK.
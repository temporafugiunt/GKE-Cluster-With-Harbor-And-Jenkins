# Cloud Environment and DevOps Pipeline Setup

This repository demonstrates the necessary steps to setup a GKE Cluster inside of GCP infrastructure for a DevOps sandbox and test application with Linux SQL Server Container and an external OAuth 2.0 / OpenID Connect STS. All source code is represented in this repository minus secret definitions defined in environment variables and loaded dynamically into Kuberetes for already exsiting external resources. This is one aspect of a twelve-factor application as originally outlined by the developers at Heroku. More information about twelve-factor applications can be found here at https://12factor.net/.

![alt text](https://github.com/temporafugiunt/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/02-Project-Architecture.PNG "Project Architecture Diagram")

Under *cloud-ops/gcp/devops-sandbox-cluster* you will find everything necessary for building out the following infrastructure in GCP:

* A 2 node linux cluster of the size n1-highmem-2 that is the DevOps cluster of this project. See the next section for general information regarding standard cluster sizes that can be used with these creation scripts, node count can also be changed.

Under *cloud-ops/kubernetes/devops-sandbox-cluster* you will find everything necessary for building out the following inside of that kubernetes cluster within GKE:

* A publicly accessible but secured Harbor instance that houses docker images and helm charts for this devops sandbox. That instance is accessible at https://sandboxregistry.ddns.net.
* A publicly accessible but secured Jenkins instance that builds the application found in this sandbox repository. That instance is accessible at https://sandboxbuilds.ddns.net.

This kubernetes cluster also tests and is the release environment for the test application contained in *src* and whose helm chart is located under *deploy*, it is accessible at https://sandboxapp.ddns.net. The application under *src* in this repository was originally based off of the React / .NET Core Okta test application found at:

https://github.com/oktadeveloper/okta-dotnetcore-react-example

That application's source is governed by the Apache 2.0 license, see its repository for more inforrmation.

# GCP VM Pricing

VMs are not the only cost related to GKE in Google Cloud, DB Server instances, dynamically provisioned volumes for kubernetes services, and Application and Container logging also represent important pricing factors, but here is a breakdown of pricing per VM for standard kubernetes cluster sizes as that represents one of the largest factors.


| Size              | vCPU | Mem   | Monthly Cost | 1 year reserved  | 3 year reserved |
|-------------------|------|-------|--------------|------------------|-----------------|
| n1-standard-1     | 1    | 3.75  |     $24.2725 | ? | ? |
| n1-highcpu-2      | 2    | 1.80  |       $36.23 | ? | ? |
| n1-standard-2     | 2    | 7.5   |       $48.55 | ? | ? |
| n1-highmem-2      | 2    | 13    |       $60.50 | ? | ? |
| n1-highcpu-4      | 4    | 3.60  |       $72.46 | ? | ? |
| n1-standard-4     | 4    | 15    |       $97.09 | ? | ? |
| n1-highmem-4      | 4    | 26    |      $121.00 | ? | ? |
| n1-highcpu-8      | 8    | 7.20  |      $144.92 | ? | ? |
| n1-standard-8     | 8    | 30    |      $194.18 | ? | ? |
| n1-highmem-8      | 8    | 52    |      $242.00 | ? | ? |
| n1-highcpu-16     | 16   | 14.40 |      $289.84 | ? | ? |
| n1-standard-16    | 16   | 60    |      $388.36 | ? | ? |
| n1-highmem-16     | 16   | 104   |      $484.00 | ? | ? |
| n1-highcpu-32     | 32   | 28.80 |      $579.68 | ? | ? |
| n1-standard-32    | 32   | 120   |      $776.72 | ? | ? |
| n1-highmem-32     | 32   | 208   |      $968.00 | ? | ? |
| n1-highcpu-64     | 64   | 57.6  |     $1159.36 | ? | ? |
| n1-standard-64    | 64   | 240   |     $1553.44 | ? | ? |
| n1-highcpu-96     | 96   | 86.4  |     $1739.04 | ? | ? |
| n1-highmem-64     | 64   | 416   |     $1936.00 | ? | ? |
| n1-standard-96    | 96   | 360   |     $2330.16 | ? | ? |
| n1-highmem-96     | 96   | 624   |     $2904.12 | ? | ? |

* The number disks allowed per node is the maximum amount of dynamic or persistent volumes that a cluster can support per node.
TODO - Verify this is the case for GKE like it is for Azure.

# Workstation Setup

The latest Google Cloud SDK and python 2.7 need to be installed on the development workstation to run initial GKE cluster provisioning operations and also to setup the proper credentials and project link to be able to run kubectl and istioctl.

# Setup GCP Cloud Infrastructure 

1) The cloud infrastructure of kubernetes and PostgreSQL can be setup by running the following command:

```bash
cd cloud-ops/gke/devops-sandbox-cluster
. ./01-Setup-ClusterAndPostgreSQLEnvironment.sh
```

2) You will be required to log in to your GCP and select the appropriate project gain access to create the proper resources for the cluster:

![alt text](https://github.com/temporafugiunt/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/01-GCPLogin.png "GCP Login")

2) You will be required to confirm the permissions you are allowing for this application to your GCP account:

![alt text](https://github.com/temporafugiunt/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/02-GCPPermissions.png "GCP Permissions")

3) After execution is complete, the script will select the new cluster to be the current cluster that any kubectl command will run against

# Setup Kubernetes Cluster Environment

1) The kubernetes environment can be setup by running the following command starting at the base of this repository:

```powershell
cd cloud-ops/kubernetes/devops-sandbox-cluster
. ./02-setup-kubernetes-environment.sh
```

2) Then install Istio, Jetstack's cert-manager, local Harbor service instances, and the local Jenkins instance can all be setup by running the following command:

```powershell
. ./03-install-devops-pipeline-apps.sh
```

3) Once these commands are run you can use `kubectl` to verify the status of pods and services of your _build_ namespace inside the cluster. You can also use the GKE Workloads view to verify all your pods are running, you will need to wait a few minutes to allow the containers to all come up as Harbor is actually several processes that need to provision their own dynamic volumes:

![alt text](https://github.com/temporafugiunt/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/02b-VerifyBuildEnvironmentStatus.PNG "Kubernetes Status")

4) istio-ingressgateway acts as the external gateway into the cluster and also interacts with Jetstack's cert-manager using ACME protocol negotiation with the Let's Encrypt Certificate Authority to setup the proper certificates for your websites in an automated way. This means at least two things:

    * You will need to verify via kubectl what your cluster's load balancing IP address is.

        ![alt text](https://github.com/temporafugiunt/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/02c-Verify-LoadBalancerIP-Istio.PNG "Find Load Balancer IP")

    * Any domains that you want to be serviced by your cluster you will have to point to the IP address of your kubernetes load balancer. We did this for our example domains:

        * https://sandboxregistry.ddns.net
        * https://sandboxbuilds.ddns.net
        * https://sandboxapp.ddns.net

    NOTE: This should be done before running the next bash script as Let's Encrypt and the cluster will attempt to create certificates for all the defined services
    in the cluster when the certificate secrets are issued in _03-install-devops-pipeline-apps.sh_.

5) Once that is setup you can access your Harbor and Jenkins instances (and soon your sandbox application). You can now start to create builds and publish the resulting docker images and helm charts to your sandbox Harbor registry.

6) You may receive a certificate error the first time you try to access a site as the Let's Encrypt certificate creation may not have finished yet. But once that is finished you will have valid certs automatically created for you like these:

![alt text](https://github.com/temporafugiunt/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/09-LetsEncryptCert.PNG "temporafugiunt Cert from Let's Encrypt Authority")

7) To simplify builds and publish operations on the cluster, you can build out your Jekinsfile(s) using the commands found in the Open Source freebyJenkinsLibrary Global Pipeline Library. That library can be found here: 

    https://github.com/freebyTech/freebyJenkinsLibrary

8) If you wish to use the commands available in this library, you will need to setup a link to the library in your Jenkins configuration like so (or a forked copy):

![alt text](https://github.com/temporafugiunt/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/10-GroovyPipelineLibrarySetup.PNG "Global Pipeline Library Settings")

9) To utilize *publish cluster* operations available in the library the first build you *absolutely need* to setup is the Open Source freebyJenkinsImage docker image so it can be pulled from your local Harbor registry. Without that image you will not be able to run the special commands necessary for simple local cluster publish operations supported by the Global Pipeline Library. Here are screen shots depicting that setup:

![alt text](https://github.com/temporafugiunt/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/05-CreateTheAgentBuild.PNG "Build Screen 1")

![alt text](https://github.com/temporafugiunt/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/06-AgentBuildSettings.PNG "Build Screen 2")

10) You will also need to setup the same project name in Harbor as is defined in the Jenkinsfile for the build of the freebyJenkinsImage repository. Here are screen shots depicting defining the correct project name:

![alt text](https://github.com/temporafugiunt/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/04-SetupPublicProject.PNG "Setup Public Project for a local build of freebyJenkinsAgent Docker Image")

9) Once the build is setup the server will automatically build the image and publish it to the playground registry as show below:

![alt text](https://github.com/temporafugiunt/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/07-AgentBuildItself.PNG "Successful Build")

![alt text](https://github.com/temporafugiunt/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/08-PublishToHarbor.PNG "Successful Publish")

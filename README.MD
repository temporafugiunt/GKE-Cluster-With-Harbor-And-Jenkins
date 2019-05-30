# Cloud Environment and DevOps Pipeline Setup

This repository demonstrates the necessary steps to setup a GKE Cluster inside of GCP infrastructure for a DevOps sandbox and test application with Linux SQL Server Container and an external OAuth 2.0 / OpenID Connect STS. All source code is represented in this repository minus secret definitions defined in environment variables and loaded dynamically into Kuberetes for already exsiting external resources. This is one aspect of a twelve-factor application as originally outlined by the developers at Heroku. More information about twelve-factor applications can be found here at https://12factor.net/.

![alt text](https://github.com/freebyTech/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/02-Project-Architecture.PNG "Project Architecture Diagram")

Under *cloud-ops/gcp/devops-sandbox-cluster* you will find everything necessary for building out the following infrastructure in GCP:

* A 3 node linux cluster of the size [Compute VM Size] that is the DevOps cluster of this project. See the next section for general information regarding standard cluster sizes that can be used with these creation scripts, node count can also be changed easily.

Under *cloud-ops/kubernetes/devops-sandbox-cluster* you will find everything necessary for building out the following inside of that kubernetes cluster within GKE:

* A publicly accessible but secured harbor instance that houses docker images and helm charts for this devops sandbox. That instance is accessible at https://sandboxregistry.ddns.net.
* A publicly accessible but secured jenkins instance that builds the application found in this sandbox repository. That instance is accessible at https://sandboxbuilds.ddns.net.

This kubernetes cluster also tests and is the release environment for the test application contained in *src* and whose helm chart is located under *deploy*, it is accessible at https://sandboxapp.ddns.net. The application under *src* in this repository was originally based off of the React / .NET Core Okta test application found at:

https://github.com/oktadeveloper/okta-dotnetcore-react-example

That application's source is governed by the Apache 2.0 license, see its repository for more inforrmation.

# GCP VM Pricing

VMs are not the only cost related to GKE in Google Cloud, DB Server instances, dynamically provisioned volumes for kubernetes services, and Application and Container logging also represent important pricing factors, but here is a breakdown of pricing per VM for standard kubernetes cluster sizes as that represents one of the largest factors.


| Size              | vCPU | Mem | Temp Storage (SSD) | Max Disks* | Monthly Cost | Long Term Pricing |
|-------------------|------|-----|--------------------|------------|--------------|-------------------|
| TODO      | TODO    | TODO   | TODO                  | Unknown          | TODO | TODO |

* The number disks allowed per node is the maximum amount of dynamic or persistent volumes that a cluster can support per node.
TODO - Verify this is the case for GKE like it is for Azure.

# Workstation Setup

The latest Google Cloud SDK and python 2.7 need to be installed on the development workstation to run initial GKE cluster provisioning operations.

# Setup Azure Cloud Infrastructure 

1) The cloud infrastructure of kubernetes can be setup by running the following command:

```bash
cd cloud-ops/gke/devops-sandbox-cluster
. ./01-Setup-Cluster.sh
```

2) You will be required to log in to your GCP and select the appropriate project gain access to create the proper resources for the cluster:

![alt text](https://github.com/freebyTech/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/01-GCPLogin.PNG "GCP Login")

2) You will be required to confirm the permissions you are allowing for this application to your GCP account:

![alt text](https://github.com/freebyTech/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/02-GCPPermissions.PNG "GCP Permissions")

3) After execution is complete, the script will select the new cluster to be the current cluster that any kubectl command will run against

# Setup Kubernetes Cluster Environment

1) The kubernetes environment can be setup by running the following command starting at the base of this repository:

```powershell
cd cloud-ops/kubernetes/devops-sandbox-cluster
. ./02-setup-kubernetes-environment.sh
```

2) Then, the nginx-ingress, acme protocol cert-manager, local harbor service instances, and the local jenkins instance can all be setup by running the following command:

```powershell
. ./03-install-devops-pipeline-apps.sh
```

3) Once these commands are run you can use `kubectl proxy` to verify the status of your build environment inside the cluster, you will need to wait a few minutes to allow the containers to all come up as harbor is actually several processes that need to provision their own dynamic volumes:

![alt text](https://github.com/freebyTech/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/02b-VerifyBuildEnvironmentStatus.PNG "Kubernetes Status")

4) cert-manager also needs to interact with Let's Encrypt to setup the proper certificates for your websites in an automated way. This means at least two things:

    * You will need to verify in Azure what your cluster's load balancing IP address is.
    * Any domains that you want to be serviced by your cluster you will have to point to the IP address of your kubernetes load balancer. We did this for our example domains:

        * https://sandboxregistry.freebytech.com
        * https://sandboxbuilds.freebytech.com
        * https://sandboxapp.freebytech.com

6) Once that is setup you can access your harbor and jenkins instances (and soon your sandbox application). You may receive a certificate error the first time you try to access a site as the Let's Encrypt certificate creation may not have finished yet. But once that is finished you will have valid certs automatically created for you like these:

![alt text](https://github.com/freebyTech/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/09-LetsEncryptCert.PNG "freebyTech Cert from Let's Encrypt Authority")

5) Harbor needs a couple of manual things setup as the harbor helm chart does not support automated setup of initial users (beyond the base admin user) and projects. Here are screen shots depicting our playground harbor setup:

![alt text](https://github.com/freebyTech/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/03-SetupHarborPublisher.PNG "Setup Jenkins Publishing Agent User")

![alt text](https://github.com/freebyTech/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/04-SetupPublicProject.PNG "Setup Public Project for freebyJenkinsAgent")

6) Once harbor is setup, you can start to create builds and publish the resulting docker images and helm charts to your sandbox harbor registry if you build out your Jekinsfiles using the commands found in our Open Source freebyJenkinsLibrary Global Pipeline Library. That library can be found here: 

    https://github.com/freebyTech/freebyJenkinsLibrary

7) If you wish to use the commands available in this library, you will need to setup a link to the library in your Jenkins configuration like so (or you can fork a copy and link to yours if you are more confortable with that):

![alt text](https://github.com/freebyTech/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/10-GroovyPipelineLibrarySetup.PNG "Global Pipeline Library Settings")

8) To fully utilize that library the first build you *absolutely need* to setup is the freebyTech freebyAgent docker image. Without that image you will not be able to run the special commands necessary for cluster publish operations supported the Global Pipeline Library for builds and release onto the local cluster. Here are screen shots depicting that setup:

![alt text](https://github.com/freebyTech/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/05-CreateTheAgentBuild.PNG "Build Screen 1")

![alt text](https://github.com/freebyTech/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/06-AgentBuildSettings.PNG "Build Screen 2")

9) Once the build is setup the server will automatically build the image and publish it to the playground registry as show below:

![alt text](https://github.com/freebyTech/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/07-AgentBuildItself.PNG "Successful Build")

![alt text](https://github.com/freebyTech/GKE-Cluster-With-Harbor-And-Jenkins/blob/develop/documentation/08-PublishToHarbor.PNG "Successful Publish")

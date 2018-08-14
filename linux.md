# Quick Start: Linux

This section walks you through an example installation sequence on 
Linux, assuming a fresh install of Ubunto 16.04.

## Prerequisites

You need to first install Docker and Python:

```shell
sudo apt update
sudo apt-get install python
sudo apt-get install python-pip
pip install requests
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
```

Now, verify the docker version.

```shell
docker --version
```

## Minikube & Kubectl

Install `minikube` and `kubectl`:

```shell
curl -Lo minikube
https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

Issue the following commands:

```shell
export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export MINIKUBE_HOME=$HOME
export CHANGE_MINIKUBE_NONE_USER=true
mkdir -p $HOME/.kube
touch $HOME/.kube/config

export KUBECONFIG=$HOME/.kube/config
```

Navigate to the `/usr/local/bin/` directory and issue the following
commands. Make sure there are no errors afterwards:

```shell
sudo -E ./minikube start --vm-driver=none
```

You can run

```shell
kubectl cluster-info
```

to verify that your Minikube cluster is up and running.

## Export the KUBECONFIG File

Locate the `KUBECONFIG` file:

```shell
sudo updatedb
locate kubeconfig
```

Export a `KUBECONFIG` variable containing the path to the
configuration file found above. For example, If your `U`
file was located in the `/var/lib/localkube/kubeconfig` directory,
the command you issue would look like this:

```shell
export KUBECONFIG=/var/lib/localkube/kubeconfig
```

## Download CORD

There are two general ways you might download CORD. The following
walks through both, but you need to follow only one. (For simplicity, we
recommend the first.)

The first simply clones the CORD `helm-chart` repository using `git`.
This is sufficient for downloading just the Helm charts you will need
to deploy the set of containers that comprise CORD. These containers
will be pulled down from DockerHub.

The second uses the `repo` tool to download all the source code that
makes up CORD, including the Helm charts needed to deploy the CORD
containers. You might find this useful if you want look at the
interals of CORD more closely.

In either case, following these instructions will result in a
directory `~/cord/helm-charts`, which will be where you go next to
continue the installation process.

### Download: `git clone`

Create a CORD directory and run the following `git` command in it:

```shell
mkdir ~/cord
cd ~/cord
git clone https://gerrit.opencord.org/helm-charts -b cord-6.0
cd helm-charts
```

### Download: `repo`

Make sure you have a `bin/` directory in your home directory and
that it is included in your path:

```shell
mkdir ~/bin
PATH=~/bin:$PATH
```

Download the Repo tool and ensure that it is executable:

```shell
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
```

Make a `/cord` directory and navigate into it:

```shell
mkdir ~/cord
cd ~/cord
```

Configure `git` with your real name and email address:

```shell
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Initialize `repo` and download the CORD source tree to your working
directory:

```shell
repo init -u https://gerrit.opencord.org/manifest -b master
repo sync
```

## Helm

Run the Helm installer script that will automatically grab the latest
version of the Helm client and install it locally:

```shell
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
```

## Tiller

Issue the following:

```shell
sudo helm init
sudo kubectl create serviceaccount --namespace kube-system tiller
sudo kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
sudo kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'      
sudo helm init --service-account tiller --upgrade
```

Install `socat` to fix a port-forwarding error:

```shell
sudo apt-get install socat
```

Issue the following and make sure no errors come up:

```shell
helm ls
```

## Deploy CORD Helm Charts

Deploy the service profiles corresponding to the `xos-core`,
`base-kubernetes`, and `demo-simpleexampleservice` helm-charts:

```shell
cd ~/cord/helm-charts
helm init
sudo helm dep update xos-core
sudo helm install xos-core -n xos-core
sudo helm dep update xos-profiles/base-kubernetes
sudo helm install xos-profiles/base-kubernetes -n base-kubernetes
sudo helm dep update xos-profiles/demo-simpleexampleservice
sudo helm install xos-profiles/demo-simpleexampleservice -n demo-simpleexampleservice
```

Use `kubectl get pods` to verify that all containers in the profile 
are successful and none are in the error state. 

> **Note:** It will take some time for the various helm charts to 
> deploy and the containers to come online. The `tosca-loader 
> `container may error and retry several times as they wait for 
> services to be dynamically loaded. This is normal, and eventually 
> the `tosca-loader` containers will enter the completed state:

## Next Steps 

This completes our example walk-through. At this point, you can do one 
of the following:

* Explore other [installation options](README.md). 
* Take a tour of the [operational interfaces](operating_cord/general.md). 
* Drill down on the internals of [SimpleExampleService](simpleexampleservice/simple-example-service.md). 

# Quick Start

This section walks you through one example installation sequence.
If you'd prefer to understand the
installation process in more depth, including the full range of
deployment options, you might start with the [Installation Guide](README.md)

The following describes how to install the R-CORD profile, plus a
`SimpleExampleService`, on a single Linux box. Once you complete these
steps, you might be interested in jumping ahead to the
[SimpleExampleService Tutorial](simpleexampleservice/simple-example-service.md)
to learn more about the make-up of a CORD service.

## Python & Docker

After a fresh install of Ubuntu 16.04 Server, install Docker and Python:

```
sudo apt update
sudo apt-get install python
sudo apt-get install python-pip
pip install requests
sudo apt install -y docker.io 
sudo systemctl start docker
sudo systemctl enable docker
```

Now, verify the docker version.

```
docker --version
```

## Minikube & Kubectl

Install `minikube` and `kubectl`:

```1
curl -Lo minikube
https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
&& chmod +x minikube
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

Issue the following commands:

```
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

```
sudo -E ./minikube start --vm-driver=none
```

If no errors come up, issue the following:

```
for i in {1..150}; do # timeout for 5 minutes
   ./kubectl get po &> /dev/null
   if [ $? -ne 1 ]; then
      break
  fi
  sleep 2
  done
```

## Export the KUBECONFIG File

Locate the `KUBECONFIG` file:

```
sudo updatedb
locate kubeconfig
```

Export a `KUBECONFIG` variable containing the path to the
configuration file found above. For example, If your `U`
file was located in the `/var/lib/localkube/kubeconfig` directory,
the command you issue would look like this:

```
export KUBECONFIG=/var/lib/localkube/kubeconfig
```

## Downloading the CORD Source Code

Make sure you have a `bin/` directory in your home directory and
that it is included in your path:

```
mkdir ~/bin
PATH=~/bin:$PATH
```

Download the Repo tool and ensure that it is executable:

```
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
```

Make a `/cord` directory and navigate into it:

```
mkdir ~/cord
cd ~/cord
```

Configure `git` with your real name and email address. To use the
Gerrit code-review tool, you will need an email address that is
connected with a registered account, so use your real name and a
email address:

```
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Run `repo init` to download the latest version of `repo` with all its
most recent bug fixes:

```
repo init -u https://android.googlesource.com/platform/manifest
repo init -u https://gerrit.opencord.org/manifest -b master
```

Pull down the CORD source tree to your working directory from the
repositories as specified in the default manifest:

```
repo sync
```

Run the Helm installer script that will automatically grab the latest
version of the Helm client and install it locally:

```
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
```

## Tiller

Issue the following:

```
sudo helm init
sudo kubectl create serviceaccount --namespace kube-system tiller
sudo kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
sudo kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'      
sudo helm init --service-account tiller --upgrade
```

Install `socat` to fix a port-forwarding error:

```
sudo apt-get install socat
```

Issue the following and make sure no errors come up:

```
helm ls
```

## Deploy CORD Helm Charts

Move `minikube` to the `/usr/local/bin/` directory:

```
sudo mv minikube /usr/local/bin/
```

Deploy the service profiles corresponding to the `xos-core`,
`base-kubernetes`, and `demo-simpleexampleservice` helm-charts:

```
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

## SimpleExampleService

Install `SimpleExampleService` and have it display “Hello World”.
Set variables for your username and password:

```
USERNAME=admin@opencord.org
PASSWORD=letmein
```

Run the TOSCA recipe to create a `SimpleExampleServiceInstance`:

```
TOSCA_URL=$(sudo minikube service xos-tosca --url)
TOSCA_FN=~/cord/orchestration/xos_services/simpleexampleservice/xos/examples/SimpleExampleServiceInstance.yaml
curl -H "xos-username: $USERNAME" -H "xos-password: $PASSWORD" -X POST
--data-binary @$TOSCA_FN $TOSCA_URL/run
```

If you notice errors come up with the above commands, deleting and
recreating the `base-kuberkenetes`, `demo-exampleservice`, and
`xos-core` containers usually fixes the errors:

```
helm del --purge base-kuberkenetes
helm del --purge demo-simpleexampleservice
helm del --purge xos-core

sudo helm install xos-core -n xos-core
sudo helm install xos-profiles/base-kubernetes -n base-kubernetes
sudo helm install xos-profiles/demo-simpleexampleservice -n demo-simpleexampleservice
```

Wait a few seconds for model policies to run, the Kubernetes
synchronizer to instantiate containers, and so on, and then view the
status by issuing the following:

```
CHAMELEON_URL=$(sudo minikube service xos-chameleon --url)
python
~/cord/orchestration/xos_services/simpleexampleservice/xos/examples//show-instances.py
$CHAMELEON_URL $USERNAME $PASSWORD
```

If everything worked properly, you should see an IP address displayed.
Enter one of the other Kubernetes containers (`kubectl get pods` can
be used to retrieve a list). Any container, for example, one of the
synchronizer containers will do. Next, run `curl` on the IP address
obtained in the previous step.

```
sudo kubectl -ti exec [container name] bash
curl [the ip address obtained in the previous step]
```

If the above worked properly, you will see the 'Hello World' HTML code appear.

If you want to modify the `SimpleExampleService` tenant message to
display “Hello Earth” instead, continue by doing the following.

> **Note:** There are multiple ways to interact with CORD
> services. The following shows one example.

A `kafka` event bus running in CORD provides a mechanism that may be used
to interact with services. `SimpleExampleService` implements an
`EventStep`, which listens on a Kafka topic and allows the
`tenant_message` to be updated.

Within the `helm-charts` directory, issue the following to make sure
`kafka` is running:

```
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm install --name cord-kafka --set replicas=1 incubator/kafka
```

Send an Event to update a web page by entering one of the other
Kubernetes containers, installing the kafka library (`pip install
kafka`) and executing the follow python. (Make sure you issue
python first to be in the correct CLI mode):

```
python
import json
from kafka import KafkaProducer
producer = KafkaProducer(bootstrap_servers="cord-kafka")
producer.send("SimpleExampleEvent", json.dumps({"service_instance": "My Simple Example Service Instance", "tenant_message": "Earth"}))
producer.flush()
```

Bash into another container (use `kubectl get pods` for a list of
containers):

```
sudo kubectl -ti exec [container name] bash
```

Curl the same IP address that was used to view the “Hello World” HTML
code. If everything worked properly, you should now see “Hello Earth”
displayed instead:

```
curl [ip address obtained earlier]
```

## Next Steps

This completes our example walk-through. At this point, you can either
explore other [installation options](README.md), or you can drill down
on the internals of [SimpleExampleService](simpleexampleservice/simple-example-service.md).

# GUI

The GUI is useful for development and demos. At the moment it is not
designed to support the scale of data one might expect in a production
deployment.

## How to Acces the GUI

Once you have CORD up and running, you can find the port on which the
GUI is available by running:

```shell
kubectl get service xos-gui


NAME      TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
xos-gui   NodePort   10.102.239.199   <none>        4000:30001/TCP   2h
```

By default, the GUI can be accessed on port `30001`

To connect to the GUI you can just open a browser at `<cluster-ip>:<gui-port`,
where `cluster-ip` is the ip of any node in your kubernetes cluster.

The *username* and *password* for the GUI are defined in
the [`xos-core`](../charts/xos-core.md) helm chart.

## Opening the GUI in minikube

The above works the same way when running on `minikube`, but
this helper is also available:

```shell
minikube service xos-gui
```

This command opens the GUI in your default browser.

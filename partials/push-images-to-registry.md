## Tag and Push Images to the Docker Registry

For the images to be consumed on the Kubernetes cluster, they need to
be first tagged, and pushed to the local registry:

Supposing your docker-registry address is:

```shell
192.168.0.1:30500
```

and that your original image name is called:

```shell
xosproject/vsg-synchronizer
```

you'll need to tag the image as

```shell
192.168.0.1:30500/xosproject/vsg-synchronizer
```

For example, you can use the *docker tag* command to do this:

```shell
docker tag xosproject/vsg-synchronizer:candidate 192.168.0.1:30500/xosproject/vsg-synchronizer:candidate
```

Now, you can push the image to the registry. For example, with *docker push*:

```shell
docker push 192.168.0.1:30500/xosproject/vsg-synchronizer:candidate
```

The image should now be in the local docker registry on your cluster.

## Identify, download, tag and push images

Sometimes you may need to identify, download, tag and push lots of images.
This can become a long and error prone operation if done manually.
For this reason, we provide a set of tool that automate procedure. The script can be found [here](https://github.com/opencord/automation-tools/tree/master/developer).

### image_from_helm.sh: identify images

The *image_from_helm.sh* script prints the list of images used by one or multiple charts. The script needs to be executed from the *helm-charts* directory. More info can be found invoking the *-h* or *--help* option of the command. The output can be piped in other utility scripts.

### pull_images.sh: pull images from DockerHub

The *pull_images.sh* script pulls from DockerHub the list of images provided in input and prints the image name if the image is correctly pulled. More info can be found invoking the *-h* or *--help* option of the command. The output can be piped in other utility scripts.

### tag_and_push.sh: tag and push images to a target Docker registry

The *tag_and_push.sh* script tags and push images to a target Docker registry (including DockerHub itself). It can add a prefix (useful for example when deploying on local registries) to images and change the tag of an image. More info can be found invoking the *-h* or *--help* option of the command. The output can be piped in other utility scripts.

### Examples:

Assume you'd like to prepare an offline SEBA installation. As such, you need to identify all the images used in the charts, download them, tag them and push them to a local Docker registry (in the example, 192.168.0.100, port 30500). From the helm-charts folder, this can be done in one command:

```shell
bash images_from_charts.sh voltha onos xos-core xos-profiles/att-workflow nem-monitoring logging | bash pull_images.sh | bash tag_and_push.sh -r 192.168.0.100:30500
```

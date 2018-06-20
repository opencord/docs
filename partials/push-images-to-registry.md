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

## Use the tag-and-push Script

Sometimes you may need to download, tag and push lots of images.
This can become a long and error prone operation if done manually.
For this reason, we provide an optional tool that automates the tag
and push procedures. The script can be found
[here](https://github.com/opencord/automation-tools/tree/master/developer).

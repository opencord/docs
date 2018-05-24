## Tag and push images to the docker registry

In order for the images to be consumed on the Kubernetes pod, they'll need to be tagged first (prefixing them with the ), and pushed to the local registry

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

The image should now be in the local docker registry on your pod.

## Use the tag-and-push script

Sometimes you may need to download, tag and push lots of images. This may become a long and error prone operation if done manually. For this reason, we provide an optional tool that automates the tag and push procedures.

The script can be found [here](https://github.com/opencord/automation-tools/tree/master/developer).

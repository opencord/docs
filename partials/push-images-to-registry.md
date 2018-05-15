Once you have your registry set up, you'll need to tag you images adding the
registry address.

Supposing your docker-registry address is:

```shell
192.168.10.12:30500
```

and that your image name is:

```shell
xosproject/vsg-synchronizer
```

You'll need to re-tag the image as

```shell
192.168.10.12:30500/xosproject/vsg-synchronizer
```

> NOTE: you can do that using the `docker tag` command:
>
> ```shell
> docker tag xosproject/vsg-synchronizer:candidate 192.168.10.12:30500/xosproject/vsg-synchronizer:candidate
> ```

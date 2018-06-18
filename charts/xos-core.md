# Deploy XOS-CORE

```shell
helm dep update xos-core
helm install -n xos-core xos-core
```

> We highly suggest to override the default values of
> `xosAdminUser` and `xosAdminPassword` with custom values

You can do it using a [`values.yaml`](https://docs.helm.sh/chart_template_guide/#values-files) file or using this command:

```shell
helm install -n xos-core xos-core --set xosAdminUser=MyUser --set xosAdminPassword=MySuperSecurePassword
```

## Deploy kafka

Some flavors of XOS require kafka, to install it please
follow refer to the [kafka](kafka.md) instructions.

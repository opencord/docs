# Deploy XOS-CORE

To deploy the XOS core and affiliated containers, run the following:

```shell
helm dep update xos-core
helm install -n xos-core xos-core
```

We highly suggest you override the default values of `xosAdminUser`
and `xosAdminPassword` with custom values. You can do it using a
[`values.yaml`](https://docs.helm.sh/chart_template_guide/#values-files)
file, or using this command:

```shell
helm install -n xos-core xos-core --set xosAdminUser=MyUser --set xosAdminPassword=MySuperSecurePassword
```

## Deploy Kafka

Some flavors of XOS require kafka. To install it, please
refer to the [kafka](kafka.md) instructions.

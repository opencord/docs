# Deploy XOS-CORE

To deploy the XOS core and affiliated containers, run the following:

```shell
helm dep update xos-core
helm install -n xos-core xos-core
```
**Nodeports exposed**

* UI: 30001
* REST: 30006
* Tosca: 30007

## Customizing security information

We strongly recommend you to override the default values of `xosAdminUser` and
`xosAdminPassword` with custom values.

You can do it using a [`values.yaml`](https://docs.helm.sh/chart_template_guide/#values-files)
file like this one:

```yaml
# custom-security.yaml
xosAdminUser: 'admin@onf.org'
xosAdminPassword: 'foobar'
```

and add it to the install command:

```shell
helm install -n xos-core xos-core -f custom-security.yaml
```

or you can override the values from the CLI

```shell
helm install -n xos-core xos-core --set xosAdminUser=MyUser --set xosAdminPassword=MySuperSecurePassword
```
> **Important!**
> If you override security values in the `xos-core` chart, you'll need to pass
> these values, either via a file or cli arguments, to all the xos related charts
> you will install, eg: `rcord-lite`, `base-openstack`, ...

## Deploy kafka

Some flavors of XOS require kafka. To install it, please
refer to the [kafka](kafka.md) instructions.

# Deploy XOS-CORE

To deploy the XOS core and affiliated containers, run the following:

{% include "../partials/helm/add-cord-repo.md" %}

```shell
helm install -n xos-core cord/xos-core
```
**Nodeports exposed**

* UI: 30001
* REST: 30006
* Tosca: 30007

## Customizing security information

We **strongly recommend** you to override the default values of *xosAdminUser* and
*xosAdminPassword* with custom values.

You can do it using a [`values.yaml`](https://docs.helm.sh/chart_template_guide/#values-files) file like this one:

```yaml
# custom-security.yaml
xosAdminUser: 'admin@onf.org'
xosAdminPassword: 'foobar'
```

and add it to the install command:

```shell
helm install -f custom-security.yaml -n xos-core cord/xos-core
```

or you can override the values from the CLI

```shell
helm install -n xos-core cord/xos-core \
    --set xosAdminUser=MyUser \
    --set xosAdminPassword=MySuperSecurePassword
```

> **Important!**
> If you override security values in the `xos-core` chart, you'll need to pass
> these values, either via a file or cli arguments, to all the xos related charts
> you will install, eg: `rcord-lite`, `base-openstack`, ...

## Deploy kafka

Some flavors of XOS require kafka. To install it, please
refer to the [kafka](kafka.md) instructions.

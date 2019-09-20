# Configure CDN

This page shows how to fine-tune CDN. The default COMAC CDN in this release is working well. However, if want more features or customize the default COMAC CDN, please refer to this page.

## CDN-Remote configuration

In the CDN-Remote Helm chart, there are two types of Docker images: (i) Ant Media image and (ii) video archive image.

### Update Ant Media images

The Ant Media image has Ant Media community version 1.7.0. If want to use the latest Ant Media or commercial Ant Media, feel free to make a new container. Then, replace the official Ant Media image with the new container. In order to replace the image, make a *YAML* file such as `cdn_var.yaml`. Then, describe a new image path like below:

```text
images:
  tags:
    antMedia: <PUT_NEW_IMAGE_HERE>
```

After that, deploy CDN-Remote with the following command:

* In the multi-cluster environment:

```bash
helm install cord/cdn-remote \
  --kube-context central \
  --namespace omec \
  --name cdn-remote \
  --values /path/to/cdn_var.yaml
```

* In the single-cluster environment:

```bash
helm install cord/cdn-remote \
  --namespace omec \
  --name cdn-remote \
  --values /path/to/cdn_var.yaml
```

### Change video clips

Currently not allowed. If must change video clips, then make a new image based on the official video archive image to have new video clips. However, there are following constraints:

* The video clips must be located in /opt/cdn/movies
* The video clips must be named as {360, 480, 720}.mp4 like the official image.
* The video clips should be encoded with H.264.

For the flexible CDN, new patch sets will be merged to allow CDN-Remote to use different video clips.

## CDN-Local configuration

CDN-Local has a single container, NGINX container. NGINX has enumerable configuration values. Among them, CDN-Local allow users possible to modify some configuration values, which is defined in `/path/to/helm-charts/cdn-services/cdn-local/values.yaml` file like below:

```text
...
events:
  workerProcesses: 1
  workerConnections: 1024
http:
  defaultType: application/octet-stream
  sendfile: "on"
  keepaliveTimeout: 65
  server:
    serverName: localhost
    location:
      root: html
      index: index.html index.htm
    error:
      code: 500 502 503 504
      page: /50x.html
      root: html
rtmp:
  chunkSize: 4000
  appRemote:
    live: "on"
  appLocal:
    movieLocation: /opt/cdn/movies
...
```

If above values should be modified, please make *YAML* file, e.g., `cdn_var.yaml`, and override those variables like below block:

```text
# cdn_var.yaml file
config:
  nginx:
    events:
      workerProcesses: 1
      workerConnections: 1024
    http:
      defaultType: application/octet-stream
      sendfile: "on"
      keepaliveTimeout: 65
      server:
        serverName: localhost
        location:
          root: html
          index: index.html index.htm
        error:
          code: 500 502 503 504
          page: /50x.html
          root: html
    rtmp:
      chunkSize: 4000
      appRemote:
        live: "on"
      appLocal:
        movieLocation: /opt/cdn/movies
```

When `cdn_var.yaml` is ready, please deploy CDN-Local with the file:

* In the multi-cluster environment:

```bash
helm install cord/cdn-local \
  --kube-context edge \
  --namespace omec \
  --name cdn-local \
  --values /path/to/cdn_var.yaml
```

* In the single-cluster environment:

```bash
helm install cord/cdn-local \
  --namespace omec \
  --name cdn-local \
  --values /path/to/cdn_var.yaml
```

Of course, possible to add more NGINX configuration values directly on `path/to/helm-charts/cdn-services/cdn-local/templates/configmap-nginx.yaml` file. In the file, there is a `data.nginx.conf` section, which generates the file including NGINX configuration values.

See [here](https://www.nginx.com/resources/wiki/start/topics/examples/full/) to know overall NGINX configuration values.

### Disable SR-IOV

The COMAC CDN is running only with SR-IOV CNI. However, will make the COMAC CDN be operating with various CNI.

## Getting help

Please tell `woojoong.kim` on `CORD` Slack channel if you see any problem.

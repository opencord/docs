# Configure CDN

This page shows how to fine-tune CDN.

## CDN-Remote configuration

In the CDN-Remote Helm chart, there are two types of Docker images: (i) Ant Media image and (ii) video archive image.

### Update Ant Media images

The Ant Media image has Ant Media community version 1.7.0. If want to use the latest Ant Media or commercial Ant Media, feel free to make a new container. Then, replace the official Ant Media image with the new container. In order to replace the image, download `helm-charts` project.

```bash
git clone https://gerrit.opencord.org/helm-charts
```

Next, go to the CDN-Remote Helm chart directory:

```bash
cd /path/to/helm-charts/cdn-services/cdn-remote
```

The image information is located in `values.yaml` file. Find `images.tags.antMedia` and modify the value.

```text
images:
  tags:
    videoArchive: docker.io/omecproject/cdn-video-repo:1.0.0
    antMedia: <PUT_NEW_IMAGE_HERE>
    depCheck: quay.io/stackanetes/kubernetes-entrypoint:v0.3.1
  pullPolicy: IfNotPresent
```

### Change video clips

Currently not allowed. If must change video clips, then make a new image based on the official video archive image to have new video clips. However, there are following constraints:

* The video clips must be located in /opt/cdn/movies
* The video clips must be named as {360, 480, 720}.mp4 like the official image.
* The video clips should be encoded with H.264.

For the flexible CDN, COMAC team will allow CDN-Remote to use different video clips **AS SOON AS POSSIBLE**.

## CDN-Local configuration

CDN-Local has a single container, NGINX container. Unfortunately, NGINX has enumerable configuration values. Among them, CDN-Local allow users possible to modify configuration values through `/path/to/helm-charts/cdn-services/cdn-local/values.yaml` file.

```text
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
    name: r
    live: "on"
  appLocal:
    name: l
    movieLocation: /opt/cdn/movies
```

Of course, we can add more NGINX configuration values directly on `path/to/helm-charts/cdn-services/cdn-local/templates/configmap-nginx.yaml` file. In the file, there is a `data.nginx.conf` section, which is the file including NGINX configuration values.

See [here](https://www.nginx.com/resources/wiki/start/topics/examples/full/) to know overall NGINX configuration values.

### Disable SR-IOV

Unfortunately, the COMAC CDN is running only with SR-IOV CNI. However, COMAC team will make the COMAC CDN be operating with various CNI.

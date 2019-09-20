# Configure OMEC Charts

This page contains lists of configuration options available with OMEC Helm charts.
All available configuration options and their default values are specified in
`values.yaml` file in each chart.

## Configure omec-data-plane

The following table lists the configurable parameters of the omec-data-plane chart
and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|`images.tags`|Image repositories and tags.||
|`images.pullPolicy`|Image pull policy.|IfNotPresent|
|`nodeSelectors.enabled`|Enable or disable node selector.|false|
|`nodeSelectors.spgwu`|Node label to be used as nodeSelector of SPGWU pod. Valid only when `nodeSelector.enabled` is true.|omec-dp|
|`resources.enabled`|Enable or disable resource requests and limits.|true|
|`resources.spgwu`|CPU and Memory resource requests and limits for SPGWU pod.|Memory: 8Gi, CPU: 4|
|`config.sriov.enabled`|Whether to use SR-IOV VF as SPGWU data plane interface.|true|
|`config.sriov.resourceList`|Provide interfaces used as a SR-IOV PF. Valid only when `config.sriov.enabled` is true.|true|
|`config.sriov.resourceList.vfio.pfNames`|PF name with its VFs are bounded to vfio-pci driver. If your cluster has multiple nodes with different interface names, provide the whole list of the interfaces.|eno1|
|`config.sriov.resourceList.netDevice.pfNames`|PF name with its VFs are bounded to PF's driver. If your cluster has multiple nodes with different interface names, provide the whole list of the interfaces|eno1|
|`config.sriov.resourceList.netDevice.drivers`|Driver name of the netDevice.|i40evf, ixgbevf|
|`config.spgwu.s1u.device`|S1U network facing interface name inside the SPGWU pod.|s1u-net|
|`config.spgwu.s1u.ip`|IP address to be assigned to S1U network interface inside the SPGWU pod.|119.0.0.3/24|
|`config.spgwu.sgi.device`|SGI network facing interface name inside the SPGWU pod.|sgi-net|
|`config.spgwu.sgi.ip`|IP address to be assigned to SGI network interface inside the SPGWU pod.|13.1.1.3/24|
|`config.spgwu.cpComm.addr`|SPGWC address for CP-DP communication.|spgwc-cp-comm|
|`config.spgwu.cpComm.port`|SPGWC port for CP-DP communication.|21|
|`config.spgwu.dpComm.nodePort.enabled`|Whether to expose `nodePort` for CP-DP comm. Set to `true` when deploying control plane and data plane to different clusters.|false|
|`config.spgwu.dpComm.nodePort.port`|Port number for CP-DP communication `nodePort`. Valid only when `config.spgwu.dpComm.nodePort.enabled` is true.|30020|
|`config.spgwu.devices`|Extra EAL arguments to pass from `ngic_dataplane`. Set "--no-pci --vdev eth\_af\_packet0,iface=s1u-net --vdev eth\_af\_packet1,iface=sgi-net" when `config.sriov.enabled` is false.|""|
|`networks.cniPlugin`|CNI plugin to attach SPGWU pod to S1U and SGI networks.|vfioveth|
|`networks.ipam`|IPAM plugin to assign IP addresses to S1U and SGI interfaces inside SPGWU pod.|static|
|`networks.s1u`|S1U network information.|subnet: 119.0.0.0/24, mask: 255.255.255.0, gateway: 119.0.0.254|
|`networks.sgi`|SGI network information.|subnet: 13.1.1.0/24, mask: 255.255.255.0, gateway: 13.1.1.254|


## Configure omec-control-plane

The following table lists the configurable parameters of the omec-control-plane chart
and their default values. omec-control-plane chart has dependency on Cassandra chart.
See [this page](https://github.com/helm/charts/tree/master/incubator/cassandra) for
Cassandra configuration options.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|`images.tags`|Image repositories and tags.||
|`images.pullPolicy`|Image pull policy.|IfNotPresent|
|`nodeSelectors.enabled`|Enable or disable node selector.|false|
|`nodeSelectors.hss`|Node label to be used as nodeSelector of HSS pod. Valid only when `nodeSelector.enabled` is true.|omec-cp|
|`nodeSelectors.mme`|Node label to be used as nodeSelector of MME pod. Valid only when `nodeSelector.enabled` is true.|omec-cp|
|`nodeSelectors.spgwc`|Node label to be used as nodeSelector of SPGWC pod. Valid only when `nodeSelector.enabled` is true.|omec-cp|
|`resources.enabled`|Enable or disable resource requests and limits.|true|
|`resources.hss`|CPU and Memory resource requests and limits for HSS pod.|Memory: 1Gi, CPU: 2|
|`resources.mme`|CPU and Memory resource requests and limits for MME pod.|Memory: 1Gi, CPU: 0.5|
|`resources.spgwc`|CPU and Memory resource requests and limits for SPGWC pod.|Memory: 5Gi, CPU: 1|
|`config.hss.hssdb`|HSSDB address.|cassandra|
|`config.hss.s6a.nodePort.enabled`|Whether to expose `nodePort` for s6a in hss side.|false|
|`config.hss.s6a.nodePort.port`|Port number for s6a `nodePort`. Valid only when `config.hss.s6a.nodePort.port` is true.|33868|
|`config.hss.acl.oldTls`|Peer whitelist extension. The peer name must be a fqdn and a special "\*" character as the first label of the fqdn.|"\*.cluster.local"|
|`config.hss.bootstrap.enabled`|Add users and mme information to HSSDB during initialization.|true|
|`config.hss.bootstrap.users`|List of users to add to the HSSDB. IMSI, MSISDN, apn, key, and opc are required for each user.||
|`config.hss.bootstrap.users`|List of mme to add to the HSSDB. ID, ISDN, and unreachability are required for each mme.||
|`config.hss.cfgFiles`|List of HSS configuration files. See [this page](https://github.com/omec-project/c3po) for C3PO HSS configuration options.||
|`config.mme.spgwAddr`|SPGWC address.|spgwc-s11|
|`config.mme.s11.nodePort.enabled`|Whether to expose `nodePort` for s11 in mme side.|false|
|`config.mme.s11.nodePort.port`|Port number for s11 `nodePort`. Valid only when `config.mme.s11.nodePort.enabled` is true.|32124|
|`config.mme.s6a.nodePort.enabled`|Whether to expose `nodePort` for s6a in mme side.|false|
|`config.mme.s6a.nodePort.port`|Port number for s6a `nodePort`. Valid only when `config.mme.s6a.nodePort.enabled` is true.|33869|
|`config.mme.cfgFiles`|List of MME configuration files. See [this page](https://github.com/omec-project/openmme/blob/master/README.txt) for MME configuration options.||
|`config.spgwc.apn`|APN setting.|apn1|
|`config.spgwc.ueIpPool`|IP range to be assigned to UE.|ip: 16.0.0.0, mask: 255.0.0.0|
|`config.spgwc.s1uAddr`|S1U address of SPGWU. It must match to `config.spgwu.s1u.ip` in omec-data-plane chart.|119.0.0.3|
|`config.spgwc.s11.nodePort.enabled`|Whether to expose `nodePort` for s11 in spgwc side.|false|
|`config.spgwc.s11.nodePort.port`|Port number for s11 `nodePort`. Valid only when `config.spgwc.s11.nodePort.enabled` is true.|32123|
|`config.spgwc.dpComm.addr`|SPGWU address for CP-DP communication.|spgwu-dp-comm|
|`config.spgwc.dpComm.port`|SPGWU port for CP-DP communication.|20|
|`config.spgwc.cpComm.nodePort.enabled`|Whether to expose `nodePort` for CP-DP comm. Set to `true` when deploying control plane and data plane to different clusters.|false|
|`config.spgwc.cpComm.nodePort.port`|Port number for CP-DP communication `nodePort`. Valid only when `config.spgwc.cpComm.nodePort.enabled` is true.|30021|
|`config.spgwc.cfgFiles`|List of SPGWC configuration files. See [this page](https://github.com/omec-project/ngic-rtc/tree/master/config) for SPGWC configuration options.||

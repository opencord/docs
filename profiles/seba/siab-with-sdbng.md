# SEBA-in-a-Box with SD-BNG (experimental support)

The following procedure describes how to set up SEBA-in-a-Box (SiaB) with embedded SD-BNG.
This use case supports only PPPoE-based authentication and IP addres assignment.
NOTE: the support is still experimental and not stable!

The default configuration of SiaB with SD-BNG incorporates an emulated OLT/ONU
provided by Ponsim and an emulated P4 BMv2 Stratum enabled ASG switch provided 
by Mininet. Mininet is also configured with two hosts that act as the upstream 
router and the PPPoE server. The Ponsim setup installs a single OLT, ONU, and RG.
The RG is able to authenticate itself and retrieve an IP address via PPPoE protocols.
Run `pon seba` to authenticate the client and retrieve an IP address.
This demonstrates end-to-end connectivity between the RG, the SD-BNG and the upstream router
 via the ONU, OLT, and ASG switch.

## Quick start

A Makefile can be used to install SEBA-in-a-Box in an automated manner on an Ubuntu 16.04 system:

```bash
mkdir -p ~/cord
cd ~/cord
git clone https://gerrit.opencord.org/automation-tools
cd automation-tools/seba-in-a-box
```

### Quick start: Build SiaB with SD-BNG

To build a SiaB with SD-BNG (including Stratum and ONOS 2.2):

```bash
SEBAVALUES=configs/seba-ponsim-sdbng.yaml FABRIC_DRIVER=stratum-bmv2 NEM_WORKFLOW=dt-workflow make [NUM_OLTS=n] [NUM_ONUS_PER_OLT=m]
```

> NOTE this command will install SEBA with the container versions that are defined in the
> file helm-charts/configs/seba-ponsim-sdbng.yaml.

You can specify the number of OLTs (up to 4) and number of ONUs per OLT (up to 4) that you want to
create.

After a successful install, you will see the message:

```text
SEBA-in-a-Box installation finished!
```

If the install fails for some reason, you can re-run the make command and the install will try to resume where it left off.

You can optionally install the logging and nem-monitoring charts during the installation by passing one or both of them (space delimited) via the INFRA\_CHARTS variable.  E.g.:

```bash
make INFRA_CHARTS='logging nem-monitoring' stable
```

Installing the nem-monitoring charts will bring up the Grafana BNG dashboard.

## Validating the install

### RG authentication and IP address assignment

Enter the RG pod in the voltha namespace:

```bash
RG_POD=$( kubectl -n voltha get pod | grep rg0-0 | awk '{print $1}' )
kubectl -n voltha exec -ti $RG_POD bash
```

If you built SiaB with multiple OLTs and ONUs, you can choose any RG to authenticate.
Inside the pod, run this command:

```bash
wpa_supplicant -i eth0 -Dwired -c /etc/wpa_supplicant/wpa_supplicant.conf
```
You won't see any output, but you can verify that the process has been complete successfully.
Running `ipconfig` you should see an output similar to the following:

```bash
$ ifconfig
eth0      Link encap:Ethernet  HWaddr de:c3:66:8d:0c:7d
          inet addr:10.22.0.193  Bcast:0.0.0.0  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:610 errors:0 dropped:403 overruns:0 frame:0
          TX packets:211 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:71489 (71.4 KB)  TX bytes:6400 (6.4 KB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

ppp0      Link encap:Point-to-Point Protocol
          inet addr:10.255.255.100  P-t-P:10.255.255.1  Mask:255.255.255.255
          UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1492  Metric:1
          RX packets:3 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:3
          RX bytes:30 (30.0 B)  TX bytes:30 (30.0 B)
```

The `ppp0` interface is the interface terminating the PPPoE tunnel on the RG, 
and the IP address assigned to the `ppp0` interface is the one assigned by the 
PPPoE server. You should receive an IP in the subnet 10.255.255.0/24.
The assignment of IP addresses is managed by the PPPoE server running as Host in Mininet.

**Before proceeding**

In the XOS GUI, the DtDriverWorkflow Service Instance should track all the state changes. 
You can check for this on the command line by running:

```bash
cordctl model list DtWorkflowDriverServiceInstance -f "authentication_state=APPROVED"
```

It should return output like this:

```bash
$ cordctl model list DtWorkflowDriverServiceInstance -f "authentication_state=APPROVED"
ID    NAME    OF_DPID                OWNER_ID    SERIAL_NUMBER    STATUS_MESSAGE                                  UNI_PORT_ID
60            of:0000d0d3e158fede    2           PSMO00000000     ONU has been validated - IP address assigned    128
```

In ONOS, the BNG app should also contain the autenticated attachment.
To check the BNG app state, SSH into ONOS (Password=rocks):

```bash
ssh-unsecure onos@127.0.0.1 -p 30115
```

and then check the registered attachment list in the BNG app by running:

```bash
bng:attachments
```

It should return an output like the following:

```bash
onos@root > bng:attachments
Registered attachments (size: 1):
{PSMO00000000/111/222/of:0000d0d3e158fede/128/DE:C3:66:8D:0C:7D=PppoeBngAttachment{
appId=DefaultApplicationId{id=197, name=org.opencord.bng}, sTag=222, cTag=111, 
macAddress=DE:C3:66:8D:0C:7D, ipAddress=10.255.255.100, lineActivated=true, 
oltConnectPoint=of:0000d0d3e158fede/128, onuSerial=PSMO00000000, qinqTpid=0, pppoeSessionId=1}}
```
The Mac address should correspond to the MAC address of the `eth0` interface of the RG,
while the IP address assigned to the `ppp0` interface of the RG.

### Ping the emulated upstream router

Ping the address `10.10.10.1` to ping the emulated upstream router that is running in Mininet.

```bash
$ ping -c 3 10.10.10.1
PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
64 bytes from 10.10.10.1: icmp_seq=1 ttl=63 time=30.3 ms
64 bytes from 10.10.10.1: icmp_seq=2 ttl=63 time=27.0 ms
64 bytes from 10.10.10.1: icmp_seq=3 ttl=63 time=21.5 ms

--- 10.10.10.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2001ms
rtt min/avg/max/mdev = 21.583/26.333/30.320/3.609 ms
```
The traffic leave the RG via the `ppp0` interface as encapsulated in PPPoE header 
and reach the upstream router as standard IP traffic. 
The PPPoE tunnel termination is performed entirely in the data plane by the ASG switch.

That’s it.  Currently it’s not possible to send traffic to destinations on the Internet.

## Restarting SEBA-in-a-Box after a reboot

After a reboot of a server running SiaB, some services (such as etcd) will likely come up in
a broken state.  The easiest thing to do in this situation is to teardown SiaB using
`make reset-kubeadm` and then rebuild it.

## Uninstall SEBA-in-a-Box

If you're done with your testing, or want to change the version you are installing,
the easiest way to remove a SiaB installation is to use the `make reset-kubeadm` target.

## Getting help

Report any problems related to SD-BNG to `Daniele` or `carmelo` on the CORD Slack channel.

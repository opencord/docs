# Network Connectivity

Network requirments are very easy. There are two networks: a management network for operators' management, and (in some use-cases) a dataplane network for end-users' traffic.

## Management network

It's the network that connects all physical devices (compute machines, fabric switches, access devices, development machine...) together, allowing them to talk one each other, and allowing operators to manage CORD.
The network is usually a 1G copper network, but this may vary deployment by deployment.
Network devices (access devices and fabric switches) usually connect to this network through a dedicated management 1G port.
If everything is setup correctly, any device should be able to communicate with the others at L3 (basically devices should ping one each other).
This network is usually used to access Internet for the underlay infrastructure setup (CORD doesn't necessarilly need Internet access). For example, you'll likely need to have Internet access through this network to install your OS or updates of it, switch software, Kubernetes.

Below you can see a diagram of a typical management network.

![CORD management network](../images/mgmt_net.png)

## Dataplane network

This is the network that carries the users' traffic. Depending on the requirements it may vary and go from 1G to any speed. This is completely separate from the management network. Usually this network has access to Internet to allow subscribers to go to Internet.

An example diagram including the dataplane network is shown below.

![CORD management network](../images/data_net.png)
# BBSim Helm Chart

This chart let you install the broadband simulator.
Note that this chart depends on [kafka](kafka.md)

```shell
helm install -n bbsim bbsim
```

## Set a different number of ONUs

You can configure the number of ONUs through a parameter in the installation:

```shell
helm install -n bbsim bbsim --set onus_per_pon_port={number_of_onus}
```

## Set a different mode

By default BBSim will bring up a certain number of ONUs and the start sending
authentication requests, via EAPOL, and DHCP requests.

You can change the behaviour via:

```shell
helm install -n bbsim bbsim --set emulation_mode="{both|aaa|default}"
```

Where:

- `both` stands for authentication and DHCP
- `aaa` stands for authentication only
- `default` will just activate the devices

## Start BBSim without Kafka

Kafka is used to aggregate the logs in CORD's [logging](logging-monitoring.md)
framework.

If you want to start BBSim without pushing the logs to kafka, you can install it
with:

```shell
helm install -n bbsim bbsim --set kafka_broker=""
```

## Provision the BBSim OLT in NEM

You can use this file to bring up the BBSim OLT in NEM: [bbsim-16.yaml](https://github.com/opencord/pod-configs/blob/master/tosca-configs/bbsim/bbsim-16.yaml).

Note that in that file there is a bit of configuration for the `dhcpl2relay` application
in ONOS that instructs it to send DHCP packet back to the OLT. This may differ
from a POD where you are sending those packets out of the fabric.
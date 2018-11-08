# BBSim Helm Chart

This chart let you install the broadband simulator.
Note that this chart depends on [kafka](kafka.md)

```shell
helm install -n bbsim bbsim
```

## Set a different number of ONUs

You can configure the number of ONUs trough a parameter in the installation:

```shell
helm install -n bbsim bbsim --set onus_per_pon_port={number_od_onus}
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
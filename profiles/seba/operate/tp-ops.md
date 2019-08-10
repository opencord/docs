# Technology Profile Operations

As explained in the configuration guide, from SEBA 2.0 onwards, it is necessary to configure a Technology Profile before an OLT can be provisioned.
However, in the SEBA 2.0-alpha release, changes to the tech-profile at runtime are not supported. We will look to add this support in future releases of VOLTHA and SEBA. It should be noted though that operators rarely have a need to change Tech profile parameters in operation, ie. QoS parameters (queues, gems, pbit mapping) are relatively static and predetermined for different service types (residential, business etc).

Nevertheless in this release, you may wish to find out more information about the assigned gem-port and tcont ids for a particular subscriber/ONU.
The following example shows a way to retrieve this information from VOLTHA's etcd database.

## Viewing Tech Profile Instances

A Tech profile when assigned to a subscriber/ONU is called an `instance` of the Tech profile.
First we need to enter the etcd container using kubectl.

```shell
~$ kubectl exec -it $(kubectl get pods | grep etcd-cluster | awk 'NR==1{print $1}') /bin/sh
```

Once inside, we can use the etcdctl tool to fetch the stored information for the profile using the technology-type (eg. xgspon) and id (eg. 64).

```shell
/ # ETCDCTL_API=3 etcdctl get --prefix  service/voltha/technology_profiles/xgspon/64
```

The first part of the output will show the original downloaded tech-profile. For example, the following output shows a single-TCONT/4-gems tech profile with id 64 for XGS-PON technology.

```shell
service/voltha/technology_profiles/xgspon/64
{
  "name": "4QueueHybridProfileMap1",
  "profile_type": "XPON",
  "version": 1,
  "num_gem_ports": 4,
  "instance_control": {
    "onu": "multi-instance",
    "uni": "single-instance",
    "max_gem_payload_size": "auto"
  },
  "us_scheduler": {
    "additional_bw": "auto",
    "direction": "UPSTREAM",
    "priority": 0,
    "weight": 0,
    "q_sched_policy": "hybrid"
  },
  "ds_scheduler": {
    "additional_bw": "auto",
    "direction": "DOWNSTREAM",
    "priority": 0,
    "weight": 0,
    "q_sched_policy": "hybrid"
  },
  "upstream_gem_port_attribute_list": [
    {
      "pbit_map": "0b00000101",
      "aes_encryption": "True",
      "scheduling_policy": "WRR",
      "priority_q": 4,
      "weight": 25,
      "discard_policy": "TailDrop",
      "max_q_size": "auto",
      "discard_config": {
        "max_threshold": 0,
        "min_threshold": 0,
        "max_probability": 0
      }
    },
    {
      "pbit_map": "0b00011010",
      "aes_encryption": "True",
      "scheduling_policy": "WRR",
      "priority_q": 3,
      "weight": 75,
      "discard_policy": "TailDrop",
      "max_q_size": "auto",
      "discard_config": {
        "min_threshold": 0,
        "max_threshold": 0,
        "max_probability": 0
      }
    },
    {
      "pbit_map": "0b00100000",
      "aes_encryption": "True",
      "scheduling_policy": "StrictPriority",
      "priority_q": 2,
      "weight": 0,
      "discard_policy": "TailDrop",
      "max_q_size": "auto",
      "discard_config": {
        "min_threshold": 0,
        "max_threshold": 0,
        "max_probability": 0
      }
    },
    {
      "pbit_map": "0b11000000",
      "aes_encryption": "True",
      "scheduling_policy": "StrictPriority",
      "priority_q": 1,
      "weight": 25,
      "discard_policy": "TailDrop",
      "max_q_size": "auto",
      "discard_config": {
        "min_threshold": 0,
        "max_threshold": 0,
        "max_probability": 0
      }
    }
  ],
  "downstream_gem_port_attribute_list": [
    {
      "pbit_map": "0b00000101",
      "aes_encryption": "True",
      "scheduling_policy": "WRR",
      "priority_q": 4,
      "weight": 10,
      "discard_policy": "TailDrop",
      "max_q_size": "auto",
      "discard_config": {
        "min_threshold": 0,
        "max_threshold": 0,
        "max_probability": 0
      }
    },
    {
      "pbit_map": "0b00011010",
      "aes_encryption": "True",
      "scheduling_policy": "WRR",
      "priority_q": 3,
      "weight": 90,
      "discard_policy": "TailDrop",
      "max_q_size": "auto",
      "discard_config": {
        "min_threshold": 0,
        "max_threshold": 0,
        "max_probability": 0
      }
    },
    {
      "pbit_map": "0b00100000",
      "aes_encryption": "True",
      "scheduling_policy": "StrictPriority",
      "priority_q": 2,
      "weight": 0,
      "discard_policy": "TailDrop",
      "max_q_size": "auto",
      "discard_config": {
        "min_threshold": 0,
        "max_threshold": 0,
        "max_probability": 0
      }
    },
    {
      "pbit_map": "0b11000000",
      "aes_encryption": "True",
      "scheduling_policy": "StrictPriority",
      "priority_q": 1,
      "weight": 25,
      "discard_policy": "TailDrop",
      "max_q_size": "auto",
      "discard_config": {
        "min_threshold": 0,
        "max_threshold": 0,
        "max_probability": 0
      }
    }
  ]
}
```

The next part of the output shows the tech-profile instance for the `BRCM22222222` ONU in our setup.
Notice that gem-port ids 1024 - 1027 have been assigned to the 4 gem-ports, and an Alloc id of 1024 has been assigned to the TCONT.

```shell
service/voltha/technology_profiles/xgspon/64/BRCM22222222
{
    "downstream_gem_port_attribute_list": [
        {
            "weight": 10,
            "aes_encryption": "True",
            "pbit_map": "0b00000101",
            "discard_config": {
                "min_threshold": 0,
                "max_probability": 0,
                "max_threshold": 0
            },
            "gemport_id": 1024,
            "max_q_size": "auto",
            "scheduling_policy": "WRR",
            "priority_q": 4,
            "discard_policy": "TailDrop"
        },
        {
            "weight": 90,
            "aes_encryption": "True",
            "pbit_map": "0b00011010",
            "discard_config": {
                "min_threshold": 0,
                "max_probability": 0,
                "max_threshold": 0
            },
            "gemport_id": 1025,
            "max_q_size": "auto",
            "scheduling_policy": "WRR",
            "priority_q": 3,
            "discard_policy": "TailDrop"
        },
        {
            "weight": 0,
            "aes_encryption": "True",
            "pbit_map": "0b00100000",
            "discard_config": {
                "min_threshold": 0,
                "max_probability": 0,
                "max_threshold": 0
            },
            "gemport_id": 1026,
            "max_q_size": "auto",
            "scheduling_policy": "StrictPriority",
            "priority_q": 2,
            "discard_policy": "TailDrop"
        },
        {
            "weight": 25,
            "aes_encryption": "True",
            "pbit_map": "0b11000000",
            "discard_config": {
                "min_threshold": 0,
                "max_probability": 0,
                "max_threshold": 0
            },
            "gemport_id": 1027,
            "max_q_size": "auto",
            "scheduling_policy": "StrictPriority",
            "priority_q": 1,
            "discard_policy": "TailDrop"
        }
    ],
    "upstream_gem_port_attribute_list": [
        {
            "weight": 25,
            "aes_encryption": "True",
            "pbit_map": "0b00000101",
            "discard_config": {
                "min_threshold": 0,
                "max_probability": 0,
                "max_threshold": 0
            },
            "gemport_id": 1024,
            "max_q_size": "auto",
            "scheduling_policy": "WRR",
            "priority_q": 4,
            "discard_policy": "TailDrop"
        },
        {
            "weight": 75,
            "aes_encryption": "True",
            "pbit_map": "0b00011010",
            "discard_config": {
                "min_threshold": 0,
                "max_probability": 0,
                "max_threshold": 0
            },
            "gemport_id": 1025,
            "max_q_size": "auto",
            "scheduling_policy": "WRR",
            "priority_q": 3,
            "discard_policy": "TailDrop"
        },
        {
            "weight": 0,
            "aes_encryption": "True",
            "pbit_map": "0b00100000",
            "discard_config": {
                "min_threshold": 0,
                "max_probability": 0,
                "max_threshold": 0
            },
            "gemport_id": 1026,
            "max_q_size": "auto",
            "scheduling_policy": "StrictPriority",
            "priority_q": 2,
            "discard_policy": "TailDrop"
        },
        {
            "weight": 25,
            "aes_encryption": "True",
            "pbit_map": "0b11000000",
            "discard_config": {
                "min_threshold": 0,
                "max_probability": 0,
                "max_threshold": 0
            },
            "gemport_id": 1027,
            "max_q_size": "auto",
            "scheduling_policy": "StrictPriority",
            "priority_q": 1,
            "discard_policy": "TailDrop"
        }
    ],
    "subscriber_identifier": "BRCM22222222",
    "us_scheduler": {
        "q_sched_policy": "hybrid",
        "direction": "UPSTREAM",
        "additional_bw": "auto",
        "weight": 0,
        "alloc_id": 1024,
        "priority": 0
    },
    "ds_scheduler": {
        "q_sched_policy": "hybrid",
        "direction": "DOWNSTREAM",
        "additional_bw": "auto",
        "weight": 0,
        "alloc_id": 1024,
        "priority": 0
    }
}

```

If there are more ONUs and subscribers in your setup, their tech-profile instances would also show up with different tcont and gem-port ids.

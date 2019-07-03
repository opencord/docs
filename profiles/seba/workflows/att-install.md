# Install AT&T Workflow

You can find a complete description of the SEBA workflow for AT&T in [this document](https://docs.google.com/document/d/1nou2c8AsRzhaDJmA_eYvFgd0Y33KiCsioveU77AOVCI/edit#heading=h.x73smxj2xaib). This pages focus exclusively on the internals details of the workflow such as actions triggered by the environment and decisions taken by NEM.

## Install the `att-workflow` chart

```shell
helm install -n att-workflow cord/att-workflow --version=1.2.4
```

> NOTE: if you have installed the `cord-platform` chart as a sum of its components,
> then you need to specify `--set att-workflow-driver.kafkaService=cord-kafka`
> during the installation command to match the name of the kafka service.

## Verify your installation and next steps

Once the installation completes, monitor your setup using `kubectl get pods`.
Wait until all pods are in *Running* state and “tosca-loader” pods are in *Completed* state.

>**Note:** The tosca-loader pods may periodically transition into *error* state. This is expected. They will retry and eventually get to the desired state.

Your POD is now installed and ready for use. To learn how to operate your POD continue to the [SEBA configuration section](../configuration.md).

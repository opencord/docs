## Preparing SEBA in a Box

We suggest to refer to [this](../../profiles/seba/siab.md) guide to deploy SEBA in a Box, but for simplicity
the commands are replicated here:

```bash
mkdir -p ~/cord
cd ~/cord
git clone https://gerrit.opencord.org/automation-tools
cd automation-tools/seba-in-a-box
make latest
``` 

> NOTE that for development we suggest do use the `latest` available version of all the components,
> but in certain cases (eg: bugfixes) you may want to use `make stable`
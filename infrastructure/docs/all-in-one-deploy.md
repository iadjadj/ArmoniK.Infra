# Table of contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Install Kubernetes](#install-kubernetes)
- [Script bash all-in-one](#script-bash-all-in-one)

# Introduction

Hereafter, You have instructions to deploy ArmoniK on dev/test environment upon your local machine with a simple deploy
script [deploy-dev-test-infra.sh](../utils/scripts/deploy-dev-test-infra.sh)

The infrastructure is composed of:

* Storage:
    * ActiveMQ
    * MongoDB
    * Redis
* Monitoring:
    * Seq server for structured log data of ArmoniK.
    * Grafana
    * Prometheus
* ArmoniK:
    * Control plane
    * Compute plane: polling agent and workers

# Prerequisites

The following software or tool should be installed upon your local Linux machine:

* If You have Windows machine, You have to install [WSL 2](../quick-deploy/localhost/docs/wsl2.md)
* [Docker](https://docs.docker.com/engine/install/)
* [JQ](https://stedolan.github.io/jq/download/)
* [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
* [Python](https://docs.python-guide.org/starting/install3/linux/) version 3
    * [hcl2](https://pypi.org/project/python-hcl2/)
    * [jsonpath-ng](https://pypi.org/project/jsonpath-ng/)
* [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

# Install Kubernetes

You must have a Kubernetes on your local machine to install ArmoniK. If not, You can follow instructions in one of the
following documentation [Install Kubernetes on dev/test local machine](../quick-deploy/localhost/docs/k3s.md).

# Script bash all-in-one

From the **root** of the repository, position yourself in directory `infrastructure/utils/scripts/`:

```bash
cd `infrastructure/utils/scripts
```

- To see the usage command:
  ```bash
  deploy-dev-test-infra.sh -h
  ```
- To deploy for the first time all infrastructure:
  ```bash
  deploy-dev-test-infra.sh -m depploy-all
  ```
- To redeploy all infrastructure:
  ```bash
  deploy-dev-test-infra.sh -m redepploy-all
  ```
- To destroy all infrastructure:
  ```bash
  deploy-dev-test-infra.sh -m destroy-all
  ```

If you want to deploy each resource independently:

- To deploy storage:
  ```bash
  deploy-dev-test-infra.sh -m deploy-storage
  ```
- To deploy monitoring:
  ```bash
  deploy-dev-test-infra.sh -m deploy-monitoring
  ```
- To deploy armonik:
  ```bash
  deploy-dev-test-infra.sh -m deploy-armonik
  ```

If you want to redeploy each resource independently:

- To redeploy storage:
  ```bash
  deploy-dev-test-infra.sh -m redeploy-storage
  ```
- To redeploy monitoring:
  ```bash
  deploy-dev-test-infra.sh -m redeploy-monitoring
  ```
- To redeploy armonik:
  ```bash
  deploy-dev-test-infra.sh -m redeploy-armonik
  ```

If you want to destroy each resource independently:

- To destroy storage:
  ```bash
  deploy-dev-test-infra.sh -m destroy-storage
  ```
- To destroy monitoring:
  ```bash
  deploy-dev-test-infra.sh -m destroy-monitoring
  ```
- To destroy armonik:
  ```bash
  deploy-dev-test-infra.sh -m destroy-armonik
  ```

If the `host_path` for shared storage for ArmoniK workers is not `/data`, You can deploy the infrastructure as follows:

```bash
deploy-dev-test-infra.sh -m deploy-all --host-path <HOST_PATH>
```

If you have a NFS filesystem as shared storage for ArmoniK workers, You deploy the infrastructure as follows:

```bash
deploy-dev-test-infra.sh \
  -m deploy-all \
  --host-path <HOST_PATH> \
  --nfs-server-ip <SERVER_NFS_IP> \
  --shared-storage-type NFS
```

### [Return to the infrastructure main page](../README.md)

### [Return to the project main page](../../README.md)
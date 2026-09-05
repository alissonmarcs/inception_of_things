# Project explanation

## `p1`

Kubernetes (K8s) manages a cluster made up of one or more nodes. A cluster can have one node, two nodes, three nodes, or many more. A node can be a physical machine, a virtual machine, or a container.

Kubernetes nodes have roles. A controller, also called a control-plane node, manages the cluster, including its API server, scheduling, and cluster state. A worker node runs application workloads inside Pods. In K3s, the controller is called a server and the worker is called an agent. K3s server nodes can also run workloads by default unless they are tainted or otherwise restricted.

`kubectl` is the command-line client used to communicate with the Kubernetes API server. It can inspect and manage Kubernetes resources, workloads, and cluster configuration. `kubectl` does not start or stop the virtual machines; Vagrant performs those operations, while `kubectl` manages the Kubernetes cluster running inside the machines.

`kubectl` reads a kubeconfig file to know which cluster to connect to, which API server endpoint to use, and how to authenticate. The kubeconfig can point to a local cluster or to a remote cluster. For example, a local machine can use a kubeconfig that points to a Kubernetes cluster hosted on AWS and manage that cluster remotely.

The `p1` folder contains a `Vagrantfile` that creates a two-node K3s cluster using VirtualBox:

- `almarcosS`, at `192.168.56.110`, is the K3s server and controller node.
- `eddos-saSW`, at `192.168.56.111`, is the K3s agent and worker node.
- Each virtual machine is configured with 2 GB of memory and 2 CPUs.
- Swap is disabled because Kubernetes requires swap to be disabled in this setup.
- The worker joins the server through the K3s API server at `192.168.56.110:6443`.

K3s creates the server kubeconfig at `/etc/rancher/k3s/k3s.yaml`. To use this kubeconfig from another machine, the API server address must be reachable from that machine. In this project, that means using `192.168.56.110` instead of `127.0.0.1`.

## How to run

From the repository root, start the 2 machines that will be two nodes of cluster, and connect to the controller node:

```bash
cd p1
vagrant up
vagrant ssh almarcosS
```

Inside the controller machine, verify that both nodes joined the cluster:

```bash
kubectl get nodes -o wide
```

The expected result is that `almarcosS` and `eddos-saSW` are both listed with the `Ready` status and their configured private IP addresses.

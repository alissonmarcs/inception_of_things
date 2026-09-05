# Project explanation

## `p1`

The `p1` directory contains a Vagrant configuration that creates two
VirtualBox virtual machines for a K3s Kubernetes cluster. One machine is
the control plane and the other is a worker node. This setup does not
contain any workload.

### Dependencies

- VirtualBox
- Vagrant
- An internet connection to download the Debian box and install K3s

### How to run

From the project root, run:

```bash
cd p1
vagrant up
```

The control plane is available at `192.168.56.110` and the worker node at
`192.168.56.111`.

To verify the cluster:

```bash
vagrant ssh almarcosS
kubectl get nodes -o wide
```

To stop and remove the virtual machines:

```bash
vagrant halt
vagrant destroy -f
```

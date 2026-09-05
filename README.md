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

## `p2`

The `p2` directory provisions one Debian 12 virtual machine running a
single-node K3s Kubernetes cluster. K3s includes Traefik as the Ingress
Controller.

The project deploys three applications:

- `app1.com`: one `http-echo` replica
- `app2.com`: three `nginxdemos/hello` replicas
- `app3.com`: one `http-echo` replica

All applications use ClusterIP Services and are routed by the Ingress
according to the HTTP `Host` header.

### Dependencies

- VirtualBox
- Vagrant
- An internet connection
- Permission to edit `/etc/hosts`

### How to run

Add the following entry to the host machine's `/etc/hosts` file:

```text
192.168.56.110 app1.com app2.com app3.com
```

Start the VM:

```bash
cd p2
vagrant up
```

Connect to the VM:

```bash
vagrant ssh vde-freiS
```

Apply the Kubernetes manifests:

```bash
kubectl apply -f /vagrant/confs/
```

Check the Pods:

```bash
kubectl get pods
```

Test the applications from the host machine:

```bash
curl http://app1.com
curl http://app2.com
curl http://app3.com
```

The VM is available at `192.168.56.110`.

To stop or remove the VM:

```bash
vagrant halt
vagrant destroy -f
```

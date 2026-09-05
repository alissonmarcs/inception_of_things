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

## `p3`

The `p3` directory contains a local GitOps environment using Docker,
k3d, Kubernetes, and Argo CD.

The setup script:

- Installs Docker, `kubectl`, k3d, and the Argo CD CLI when needed
- Creates a local k3d Kubernetes cluster
- Creates the `argocd` and `dev` namespaces
- Installs Argo CD
- Exposes the Argo CD server at `https://localhost:30777`
- Creates an Argo CD Application named `will-playground`
- Automatically synchronizes the `manifests` directory from Git into the
  `dev` namespace

### Dependencies

- Docker
- Linux or Ubuntu-based environment
- Internet connection
- `sudo` access
- A browser for accessing Argo CD

The `install_dependencies.sh` script installs the following tools:

- Docker
- `kubectl`
- k3d
- Argo CD CLI

### How to run

From the project root:

```bash
cd p3/scripts
chmod +x install_dependencies.sh setup_argocd.sh
./setup_argocd.sh
```

The script prints the initial Argo CD administrator password and attempts
to open Argo CD in the browser.

Argo CD is available at:

```text
https://localhost:30777
```

Login with:

```text
Username: admin
Password: value printed by setup_argocd.sh
```

To inspect the cluster and deployed application:

```bash
kubectl get nodes
kubectl get applications -n argocd
kubectl get all -n dev
```

### Test the application

The application is deployed to the `dev` namespace and exposed on port
`30888`.

Initially, the application uses `wil42/playground:v2`:

```bash
curl 127.0.0.1:30888
```

Expected response:

```json
{"status":"ok", "message": "v2"}
```

Change the image in [`deployment.yaml`](https://github.com/alissonmarcs/vde-frei/blob/main/manifests/deployment.yaml)
from:

```yaml
image: wil42/playground:v2
```

to:

```yaml
image: wil42/playground:v1
```

Commit and push the change. Argo CD automatically detects the Git
repository change and synchronizes the application in the `dev`
namespace.

Verify the updated deployment:

```bash
kubectl get pods -n dev
```

Test the application again:

```bash
curl 127.0.0.1:30888
```

Expected response:

```json
{"status":"ok", "message": "v1"}
```

To delete the local k3d cluster:

```bash
k3d cluster delete
```

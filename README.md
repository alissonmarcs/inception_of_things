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

## `bonus`

The `bonus` directory provisions a local GitOps environment with k3d,
Kubernetes, GitLab, Garage object storage, CloudNativePG, and Argo CD.
GitLab is configured as the source repository for the Argo CD application
defined in [`bonus/confs/will42.yaml`](bonus/confs/will42.yaml).

The setup creates:

- A k3d cluster with HTTP, HTTPS, GitLab SSH, Argo CD, and application ports
  exposed on `10.0.2.15`
- Valkey for GitLab caching
- A PostgreSQL 17 database managed by CloudNativePG
- Garage as the S3-compatible object storage backend for GitLab
- GitLab using the Gateway API and a self-signed certificate
- Argo CD with automatic synchronization enabled

### Dependencies

- Docker
- k3d
- `kubectl`
- Helm
- Argo CD CLI
- `sudo` access to install the GitLab CA certificate
- Internet access to download container images, Helm charts, and Kubernetes
  manifests

Add the chart repositories before running the setup:

```bash
helm repo add valkey https://valkey.io/valkey-helm/
helm repo add garage https://kubernetes-sigs.github.io/garage-operator
helm repo add gitlab https://charts.gitlab.io/
helm repo update
```

### How to run

Run the setup script from its directory:

```bash
cd bonus/scripts
chmod +x setup_gitlab.sh setup_garage.sh
./setup_gitlab.sh
```

`setup_gitlab.sh` creates the cluster, installs the dependencies, configures
Garage buckets and credentials, installs GitLab and Argo CD, and adds the
GitLab CA certificate to the host trust store. It also prints the GitLab root
password and the Argo CD administrator password.

GitLab is available at:

```text
https://gitlab.10.0.2.15.nip.io
```

Log in with username `root` and the password printed by the setup script.
Argo CD is available at `https://10.0.2.15:30777`; use username `admin` and
the printed administrator password. The Argo CD CLI login performed by the
script skips TLS verification because the local certificate is self-signed.

After creating or importing the GitLab repository referenced by
`will42.yaml`, apply the Argo CD application:

```bash
kubectl apply -f ../confs/will42.yaml
kubectl get applications -n argocd
kubectl get all -n dev
```

The application is synchronized automatically from the repository's
`manifests` directory into the `dev` namespace. Port `30888` is exposed by
the k3d cluster for the deployed application.

From the project root, remove the environment and run the setup again:

```bash
k3d cluster delete
cd bonus/scripts
./setup_gitlab.sh
```

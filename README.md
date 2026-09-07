<div align="center">
	<h1>Inception of Things</h1>
	<img src="https://thumb.wikimedia.org/wikipedia/commons/thumb/3/39/Kubernetes_logo_without_workmark.svg/960px-Kubernetes_logo_without_workmark.svg.png?utm_source=commons.wikimedia.org&utm_campaign=index&utm_content=thumbnail" alt="Pipex project badge of 42" width="150" height="150"/>
	<p align="center">A 42 specialization project that introduce to Kubernetes world.</p>
</div>

<div align="center">
	<h2>Final score</h2>
	<img src="https://i.imgur.com/dL7Srhr.png" alt="Project scored with 125/100">

---

 [`Dependencies`](#dependencies) <br>
 [`p1`](#p1) <br>
 [`p2`](#p2) <br>
 [`p3`](#p3) <br>
 [`bonus`](#bonus)
</div>

## Dependencies

Virtualbox, vagrant, kubectl, helm, argocd cli, docker, k3d, curl.

Also, the following helm repos, plugin and operator are need

```bash
helm repo add valkey https://valkey.io/valkey-helm/
helm plugin install https://github.com/aslafy-z/helm-git
helm repo add garage "git+https://git.deuxfleurs.fr/Deuxfleurs/garage.git@script/helm?ref=v2.2.0"
kubectl apply --server-side -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.28/releases/cnpg-1.28.0.yaml
```


## `p1`

Two node k3s cluster. Nodes are Debian 13.1 virtual machines created and configured with vagrant. This setup has no workload.

### How to run

From the project root, run:

```bash
cd p1
vagrant up
```

The control plane is available at `192.168.56.110` and the worker node at
`192.168.56.111`.

To list cluster nodes

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

Single node k3s cluster with three deployments, one of them with 3 replicas, and ingress with Host based rules.

The project deploys three applications:

- `app1.com`: one `http-echo` replica
- `app2.com`: three `nginxdemos/hello` replicas
- `app3.com`: one `http-echo` replica

All applications use ClusterIP Services and are routed by the Ingress
according to the HTTP `Host` header.

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

Single node k3d cluster, with `argocd` and `dev` namespaces. ArgoCD [CRD](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) and application `will-playground` (`p3/confs/will42.yaml`) are installed at `argocd` and will monitor [deployment.yaml](https://github.com/alissonmarcs/vde-frei/blob/main/manifests/deployment.yaml) for new commits, automatically deploying new infras on `dev`.


### Example of automatic workload update

```bash
curl -w '\n' http://0.0.0.0:30888
{"status":"ok", "message": "v2"}
```

After chaning [deployment.yaml](https://github.com/alissonmarcs/vde-frei/blob/main/manifests/deployment.yaml) to use `image: wil42/playground:v1`


```bash
curl -w '\n' http://0.0.0.0:30888
{"status":"ok", "message": "v1"}
```

### How to run

From the project root:

```bash
cd p3/scripts
chmod +x install_dependencies.sh setup_argocd.sh
./setup_argocd.sh
```

ArgoCD web interface are available at:

```text
https://127.0.0.1:30777
```

Login with:

```text
Username: admin
Password: value printed by setup_argocd.sh
```

To inspect the cluster and deployed application:

```bash
kubectl get nodes
kubectl get all -n argocd
kubectl get all -n dev
```

To test workload, see [Example automatic worload update](#example-of-automatic-workload-update)


To delete the local k3d cluster:

```bash
k3d cluster delete
```

## `bonus`

Single node k3d cluster, Gitlab's helm chart installed and configured, ArgoCD will not more watch remote Github repo, but the one we created in local Gitlab.

- Config Gitlab's helm chart and its dependencies.
  - Postgres 17 with [CloudNativePG](https://cloudnative-pg.io/) [operator](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)
  - Valkey chart
  - Garage object store chart
- ArgoCD application to monitor repo on local Gitlab.

### How to run

Run the setup script from its directory:

```bash
cd bonus/scripts
chmod +x setup_gitlab.sh setup_garage.sh
./setup_gitlab.sh
```

`setup_gitlab.sh` creates k3d cluster, installs Gitlab and its dependencies, install ArgoCD, create `will-playground` ArgoCD's application, adds the GitLab CA certificate to the host trust store, make argocd trust Gitlab certificate. It also prints the GitLab and ArgoCD credentials to loging in web interfaces.

GitLab is available at:

```text
https://gitlab.10.0.2.15.nip.io
```

Open it in browser, and create repo ArgoCD will watch. Repo should be named `vde-frei` and have
`manifests` folder, like ArgoCD application expects

```yml
# bonus/confs/will42.yaml
source:
  repoURL: https://gitlab.10.0.2.15.nip.io/root/vde-frei.git 
    targetRevision: HEAD  
    path: manifests 
```

To test workload, see [Example automatic worload update](#example-of-automatic-workload-update)

To delete entire project, delete de cluster

```bash
k3d cluster delete
```

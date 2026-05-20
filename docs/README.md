## Conceitos centrais do Kubernetes

- Clusters e nós
- Componentes do Control Plane
- Componentes do Worker node
- O comando `kubectl`

### Clusters e nós

Cluster é uma coleção de nós. O propósito do k8s é gerenciar clusters.

Nó é uma máquina, pode ser VM ou máquina real. É comum ter um nó
que exclusivamente gerencia o cluster, e outros nós que rodam as aplicações em containers.

O nó que gerencia o cluster é chamado de control plane.

O nó que roda aplicações é chamado de worker node.

Também é comum, especialmente em desenvolvimento, ter um cluster de um único nó, que roda serviços do control plane e serviços do worker. 

No k3s, uma distribuição leve do k8s, control plane é chamado de server, e o worker node é chamado de agente.

### Componentes do control plane 

- **kube-apiserver** é a API central que gerencia o cluster. Diversos componentes do k8s são clientes do kube-apiserver.

- **etcd** é o banco de dados do cluster.

E vários outros

### Componentes do worker node

- **kubelet** é o que gerencia um worker node. Ele é cliente do kubeapi-server. Exemplo de task do kubelet: ele recebe do um kube-apiserver pedido de criação de container, e o envia ao
runtime de container.

- **runtime de container** é o que de fato roda os containers.

E vários outros.

### O comando `kubectl`

Esse comando é cliente do **kube-apiserver**, e é com ele que um cluster é gerenciado. 

No control plane, para listar todos os nós:

```bash
kubectl get nodes -o wide
```

#### Como gerenciar o cluster pelo worker node ?

Com o `kubectl` sendo cliente do **kube-apiserver**, significa que é possível gerenciar um cluster remoto.

Exemplo:

- um cluster rondando na AWS gerenciado em sua máquina local através do `kubectl`.

- gerenciamento do cluster a partir do worker node.

O requisito é que a máquina rodando o `kubectl` tenha acesso a rede do cluster e tenha um **kubeconfig** válido.

No control plane, existe o `/etc/rancher/k3s/k3s.yaml` que diz ao `kubectl` como se conectar ao cluster, esse é o kubeconfig. Basta você copiar o `/etc/rancher/k3s/k3s.yaml` para o worker node:

```bash
scp /etc/rancher/k3s/k3s.yaml 192.168.56.111:/home/vagrant/
```

Ao pedir senha, use vagrant.

E no worker node, é necessário mudar a linha `server: https://127.0.0.1:6443` para `server: https://192.168.56.110:6443` no `k3s.yaml`:

```yaml
# /home/vagrant/k3s.yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ...
    server: https://192.168.56.110:6443
  name: default
contexts:
- context:
    cluster: default
    user: default
  name: default
current-context: default
kind: Config
users:
- name: default
  user:
    client-certificate-data: ...
    client-key-data: ...
```

Agora sim:

```bash
kubectl get nodes -o wide --kubeconfig ./k3s.yaml
```

## Links úteis

- [O que é um cluster](https://kubernetes.io/docs/tutorials/kubernetes-basics/create-cluster/cluster-intro/)

- [Arquitetura do cluster](https://kubernetes.io/docs/concepts/architecture/)
## Conceitos centrais do Kubernetes

- Clusters e nós
- Componentes do Control Plane
- Componentes do Worker
- O comando `kubectl`

### Clusters e nós

Cluster é uma coleção de nós. O propósito do k8s é gerenciar clusters.

Nó é uma máquina, pode ser VM ou máquina real. É comum ter um nó
que exclusivamente gerência o cluster, e outros nós que rodam as aplicações em containers.

O nó que gerencia o cluster é chamado de control plane.

O nó que roda aplicações é chamado de worker node.

Também é comum, especialmente em desenvolvimento, ter um cluster de um único nó, que roda serviços do control plane e serviços do worker. 

No k3s, uma distribuição leve do k8s, control plane é chamado de server, e o worker node é chamado de agente.

### Componentes do control plane 

- **kube-apiserver** é a API central que gerencia o cluster. Vários outros componentem são clientes 
do kube-apiserver.

- **etcd** é o banco de dados do cluster.

E vários outros

### Componentes do worker node

- **kubelet** é o que gerencia um worker node. Ele é cliente do kubeapi-server. Exemplo de task do kubelet: ele recebe do kubeapi-server pedido de criação de container, e o envia ao
runtime de container.

- **runtime de container** é o que de fato roda os containers.

E vários outros.

### O comando `kubectl`

Esse comando é cliente do **kubeapi-server**, e é com ele que um cluster é gerenciado. 

No control plane, para listar todos os nós:

```bash
kubectl get nodes -o wide
```

#### Como gerenciar o cluster pelo worker node ?

Com o `kubectl` sendo cliente do **kubeapi-server**, significa que é possível gerenciar um cluster remoto. Exemplo: você tem um cluster rondando na AWS, e gerencia ele em sua máquina local através do `kubectl`. Outro exemplo, você deseja gerenciar o cluster pelo worker node.

No control plane, existe o `/etc/rancher/k3s/k3s.yaml` que diz ao `kubectl` como se conectar ao cluster. Basta você copiar o `/etc/rancher/k3s/k3s.yaml` ao worker node:

```bash
scp /etc/rancher/k3s/k3s.yaml 192.168.56.111:/home/vagrant/
```

Ao pedir senha, use vagrant.

E no worker node, você precisa mudar `server: https://127.0.0.1:6443` para `server: https://192.168.56.110:6443` no `k3s.yaml`. Agora sim:

```bash
kubectl get nodes -o wide
```

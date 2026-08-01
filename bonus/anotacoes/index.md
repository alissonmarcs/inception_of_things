### service load balancer
$ kubectl describe service/envoy-default-gitlab-gw-f1533772
Name:                     envoy-default-gitlab-gw-f1533772
Namespace:                default
Labels:                   app.kubernetes.io/component=proxy
                          app.kubernetes.io/managed-by=envoy-gateway
                          app.kubernetes.io/name=envoy
                          gateway.envoyproxy.io/owning-gateway-name=gitlab-gw
                          gateway.envoyproxy.io/owning-gateway-namespace=default
Annotations:              <none>
Selector:                 app.kubernetes.io/component=proxy,app.kubernetes.io/managed-by=envoy-gateway,app.kubernetes.io/name=envoy,gateway.envoyproxy.io/owning-gateway-name=gitlab-gw,gateway.envoyproxy.io/owning-gateway-namespace=default
Type:                     LoadBalancer
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.43.53.194
IPs:                      10.43.53.194
External IPs:             10.0.2.15
Port:                     http-80  80/TCP
TargetPort:               10080/TCP
NodePort:                 http-80  31844/TCP
Endpoints:                10.42.0.37:10080
Port:                     tcp-22  22/TCP
TargetPort:               10022/TCP
NodePort:                 tcp-22  30907/TCP
Endpoints:                10.42.0.37:10022
Session Affinity:         None
External Traffic Policy:  Local
Internal Traffic Policy:  Cluster
HealthCheck NodePort:     30294
Events:
  Type    Reason                Age   From                   Message
  ----    ------                ----  ----                   -------
  Normal  EnsuringLoadBalancer  22m   service-controller     Ensuring load balancer
  Normal  AppliedDaemonSet      22m   service-lb-controller  Applied LoadBalancer DaemonSet kube-system/svclb-envoy-default-gitlab-gw-f1533772-db99c842

### pod que o daemon set criou

$ kubectl describe -n kube-system pod/svclb-envoy-default-gitlab-gw-f1533772-db99c842-jsnhn
Name:                 svclb-envoy-default-gitlab-gw-f1533772-db99c842-jsnhn
Namespace:            kube-system
Priority:             2000001000
Priority Class Name:  system-node-critical
Service Account:      svclb
Node:                 <none>
Labels:               app=svclb-envoy-default-gitlab-gw-f1533772-db99c842
                      controller-revision-hash=666dd7b47f
                      pod-template-generation=1
                      svccontroller.k3s.cattle.io/svcname=envoy-default-gitlab-gw-f1533772
                      svccontroller.k3s.cattle.io/svcnamespace=default
Annotations:          <none>
Status:               Pending
IP:
IPs:                  <none>
Controlled By:        DaemonSet/svclb-envoy-default-gitlab-gw-f1533772-db99c842
Containers:
  lb-tcp-80:
    Image:      rancher/klipper-lb:v0.4.9
    Port:       80/TCP (lb-tcp-80)
    Host Port:  80/TCP (lb-tcp-80)
    Environment:
      SRC_PORT:    80
      SRC_RANGES:  0.0.0.0/0
      DEST_PROTO:  TCP
      DEST_PORT:   31844
      DEST_IPS:     (v1:status.hostIPs)
    Mounts:        <none>
  lb-tcp-22:
    Image:      rancher/klipper-lb:v0.4.9
    Port:       22/TCP (lb-tcp-22)
    Host Port:  22/TCP (lb-tcp-22)
    Environment:
      SRC_PORT:    22
      SRC_RANGES:  0.0.0.0/0
      DEST_PROTO:  TCP
      DEST_PORT:   30907
      DEST_IPS:     (v1:status.hostIPs)
    Mounts:        <none>
Conditions:
  Type           Status
  PodScheduled   False
Volumes:         <none>
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     CriticalAddonsOnly op=Exists
                 node-role.kubernetes.io/control-plane:NoSchedule op=Exists
                 node-role.kubernetes.io/master:NoSchedule op=Exists
                 node.kubernetes.io/disk-pressure:NoSchedule op=Exists
                 node.kubernetes.io/memory-pressure:NoSchedule op=Exists
                 node.kubernetes.io/not-ready:NoExecute op=Exists
                 node.kubernetes.io/pid-pressure:NoSchedule op=Exists
                 node.kubernetes.io/unreachable:NoExecute op=Exists
                 node.kubernetes.io/unschedulable:NoSchedule op=Exists
Events:
  Type     Reason            Age                  From               Message
  ----     ------            ----                 ----               -------
  Warning  FailedScheduling  27m                  default-scheduler  0/1 nodes are available: 1 node(s) didn't have free ports for the requested pod ports. preemption: 0/1 nodes are available: 1 node(s) didn't have free ports for the requested pod ports.
  Warning  FailedScheduling  6m29s (x7 over 27m)  default-scheduler  0/1 nodes are available: 1 node(s) didn't have free ports for the requested pod ports. preemption: 0/1 nodes are available: 1 node(s) didn't have free ports for the requested pod ports.

### values.yaml do gitlab

109     service:
110       type: NodePort
111       nodePort: 32022

precisa ter essa porta mapeada tbm


### kubectl get all

NAME                                       TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                                            AGE
service/envoy-default-gitlab-gw-f1533772   LoadBalancer   10.43.53.194    10.0.2.15     80:31844/TCP,22:30907/TCP                          10m

### comando k3d

k3d cluster create -p '10.0.2.15:80:80@loadbalancer' -p '10.0.2.15:20:20@loadbalancer' -p '10.0.2.15:32022:32022@loadbalancer' --k3s-arg "--disable=traefik@server:0"


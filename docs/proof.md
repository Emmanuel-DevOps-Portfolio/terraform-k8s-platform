# Cluster Validation & Proof
## Infrastructure Summary

Provisioned using:

- Terraform (VPC, subnets, route tables, IGW, Security Groups, EC2)

- Ansible (OS bootstrap + Kubernetes installation)

- kubeadm (cluster initialization)

- Calico (CNI networking)

- containerd (runtime)

Region: eu-west-1
Cluster type: kubeadm on EC2 (not EKS)

## Node Status

```bash
kubectl get nodes -o wide
```
Expected Output:

- 2 nodes

- Control plane role assigned

- Both nodes in Ready state

- Kubernetes version v1.29.x

- containerd runtime

Screenshot: ![Node Status](nodes.png)



## System Pods Validation

```bash
kubectl get pods -A
```
Validated components:

- etcd

- kube-apiserver

- kube-controller-manager

- kube-scheduler

- kube-proxy

- CoreDNS

- Calico (node + controllers)

- ingress-nginx controller

Screenshot: ![System Pods](system-pods.png)


## Workload Deployment

Deployed test workload:

```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
```
Service verification:

```bash
kubectl get svc nginx
```
NodePort successfully assigned and reachable externally after opening Security Group range 30000–32767.

## Ingress Validation

Installed ingress-nginx controller.

Controller Service:

```bash
kubectl -n ingress-nginx get svc ingress-nginx-controller
```

## HTTP NodePort assigned (example: 31844).

Ingress Resource:

```bash
kubectl get ingress
kubectl describe ingress nginx-ingress
```

External Validation:

Accessed via:

http://<worker_public_ip>:31844/

Screenshot:

![Ingress Service](ingress-svc.png)

![Ingress Browser Test](ingress-browser.png)

## Networking Validation

Confirmed:

   - Correct public route table (0.0.0.0/0 → IGW)

   - Security Group rules for:

      - SSH (restricted to public IP)

      - Kubernetes API (6443)

      - NodePort range (30000–32767)

  - Calico CNI functional (pod-to-pod communication operational)

## Real-World Debugging Resolved

During build, the following issues were identified and fixed:

1. Incorrect route table CIDR (10.0.1.0/16 instead of 0.0.0.0/0) blocking SSH

2. Dynamic ISP public IP causing SSH lockout

3. kubeadm preflight failure due to insufficient memory on t3.micro

4. NodePort inaccessible due to missing Security Group range

## Result

Fully functional Kubernetes cluster provisioned from scratch using Infrastructure as Code and configuration management.

External traffic successfully routed through:

Internet → EC2 Node → Ingress Controller → Kubernetes Service → Pod
















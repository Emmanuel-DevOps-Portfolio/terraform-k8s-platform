# Terraform Kubernetes Platform (AWS + Ansible + kubeadm)
## Project Overview

This project provisions a production-style Kubernetes cluster on AWS using:

- Terraform for infrastructure provisioning

- Ansible for configuration management

- kubeadm for cluster initialization

- Calico for pod networking

- containerd as the container runtime

The cluster runs on EC2 instances inside a custom VPC and exposes workloads via NodePort.

## Architecture

Laptop
→ Terraform
→ AWS VPC + Subnets + IGW + Route Tables
→ Security Groups (restricted SSH + API)
→ EC2 (Control Plane + Worker)
→ Ansible Bootstrap
→ kubeadm Cluster
→ Calico CNI
→ Nginx Workload
→ NodePort Exposure


## Infrastructure Components

### Networking

- Custom VPC (10.0.0.0/16)
- Public subnets in multiple AZs
- Internet Gateway
- Public route table with 0.0.0.0/0
- Security group with:

    - Restricted SSH
    - Restricted Kubernetes API
    - NodePort range (30000–32767)
 
## Compute

- EC2 Control Plane (t3.small)
- EC2 Worker Node (t3.micro)
- Ubuntu 22.04 LTS
- containerd runtime

## Automation Stack

### Terrafform

- Remote backend (S3)
- State locking (DynamoDB)
- Infrastructure lifecycle management

## Ansible

- OS preparation
- Swap disablement
- Kernel module configuration
- containerd installation
- kubelet / kubeadm / kubectl installation
- kubeadm init automation
- Worker join automation

## Cluster Validation

```bash
kubectl get nodes -o wide
kubectl get pods -A
```

Both nodes reach Ready state.

Calico CNI installed and operational.

## Workload Deployment

```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
```

NodePort service successfully exposed externally after updating Security Group to allow 30000–32767.

## Debugging Experience

- During development, the following real-world issues were identified and resolved:

- Incorrect route table CIDR (10.0.1.0/16 instead of 0.0.0.0/0) blocking SSH

- Dynamic ISP public IP breaking SSH access due to restricted Security Group rules

- kubeadm memory preflight failure on t3.micro (resolved by resizing control plane)

- NodePort external access blocked due to missing Security Group range


## Key Learnings

- AWS networking fundamentals (VPC, IGW, route tables, security groups)

- Infrastructure as Code best practices

- State management with remote backend

- Kubernetes cluster lifecycle management

- CNI networking model

- Secure exposure of workloads

## Future Improvements

- Ingress Controller (NGINX)

- Helm-based application deployment

- Monitoring stack (Prometheus + Grafana)

- Migration to EKS

- CI/CD automation























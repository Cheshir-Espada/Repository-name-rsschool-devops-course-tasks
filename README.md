# Task 3 – AWS K3s Cluster

This Terraform project provisions a **K3s cluster on AWS** using Free Tier instances.

 Architecture

| Component      | Instance Type | Purpose          |
|----------------|----------------|------------------|
| Bastion Host   | `t2.micro`     | SSH, kubectl     |
| Master Node    | `t3.micro`     | k3s server       |
| Worker Node    | `t3.micro`     | k3s agent        |
| Network        | Public VPC     | /24, IGW, SG     |

---

  Deploy Instructions

 1. Init and Apply

```bash
terraform init
terraform apply

After apply, copy the bastion_public_ip from the output.

Access the Cluster
ssh -i k3s-key ec2-user@<bastion_public_ip>
sudo /usr/local/bin/k3s kubectl get nodes

Test Workload
kubectl apply -f https://k8s.io/examples/pods/simple-pod.yaml
kubectl get all --all-namespaces

Optional: Local kubectl access
# On Bastion
sudo cat /etc/rancher/k3s/k3s.yaml > ~/k3s.yaml
sed -i "s/127.0.0.1/<bastion_public_ip>/" ~/k3s.yaml

# On your laptop
scp -i k3s-key ec2-user@<bastion_public_ip>:~/k3s.yaml .
export KUBECONFIG=$PWD/k3s.yaml
kubectl get nodes

Teardown
terraform destroy

Notes

SSH key pair required: k3s-key and k3s-key.pub
Tested with Terraform v1.8+
Designed for AWS Free Tier

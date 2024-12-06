# Kubernetes the Hard Way on AWS

This CloudFormation stack provides the hardware required to complete the steps outlined in [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/01-prerequisites.md) by Kelsey Hightower. It sets up the infrastructure needed for a minimal Kubernetes cluster, including a jumpbox, control plane server, and worker nodes.

## Features

- **Custom Public VPC**:
  - Automatically provisions a dedicated public VPC with a subnet.
  - Configures an Internet Gateway for internet connectivity.
  
- **Instances**:
  - Jumpbox: A bastion host for managing access to other resources in the cluster.
  - Server: The Kubernetes control plane.
  - Node1 and Node2: Kubernetes worker nodes.
  
- **Security Groups**:
  - Restricted SSH access to the jumpbox from a specific IP (`AdminIP`).
  - Secure intra-cluster communication.
  
- **Tagging**:
  - Resources are tagged with `Project: kubernetes-the-hard-way` for easy identification.

- **Custom Parameters**:
  - Allows customization of key settings such as:
    - SSH Key Pair (`KeyName`).
    - Admin IP for SSH access (`AdminIP`).
    - Amazon Machine Image ID (`AMIId`).

## Requirements

1. **AWS CLI**:
   - Install and configure the [AWS CLI](https://aws.amazon.com/cli/).
2. **Existing Key Pair**:
   - Ensure you have an existing EC2 Key Pair for SSH access to the instances.
3. **Administrator Permissions**:
   - The AWS user deploying this stack must have sufficient permissions to create VPCs, EC2 instances, and security groups.

## Parameters

- Find the correct AMI for your region. I've used Debian 12 ARM, but probably any other Debian based distribution will do.
- Create and download a Key Pair. **EC2 -> Network & Security -> Key Pairs**

| Parameter | Description | Default Value |
|-----------|-------------|---------------|
| `KeyName` | Name of an existing EC2 Key Pair for SSH access. | None (must be provided) |
| `AdminIP` | Your IP address (in CIDR format) to allow SSH access. | None (must be provided) |
| `AMIId`   | The AMI ID to use for the instances and your AWS region. (Debian 12 works fine) | `ami-0056a7c4c0c442db6` |


## Usage

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/kubernetes-the-hard-way-aws.git
   cd kubernetes-the-hard-way-aws

2. Create a parameters.yaml file with your specific values:

```
- ParameterKey: KeyName
  ParameterValue: my-ec2-keypair
- ParameterKey: AdminIP
  ParameterValue: 192.168.1.1/32
- ParameterKey: AMIId
  ParameterValue: ami-0abcdef1234567890
```

3. Deploy the CloudFormation stack:
```
aws cloudformation create-stack \
  --stack-name k8s-cluster-with-vpc \
  --template-body file://k8s-cluster.yaml \
  --parameters file://parameters.yaml 
```

4. Monitor the stack creation:

```
aws cloudformation describe-stacks --stack-name k8s-cluster-with-vpc
```
5. Access the Jumpbox:
You need to add your key to your ssh-agent so it can be used to jump to the other nodes. `-A` forwards your key.
```
ssh-add my-keypair.pem
ssh -A -i my-keypair.pem admin@<Jumpbox_Public_IP>
```

6. From the jumpbox, access the server and nodes:
```
ssh admin@<Private_IP>
```

## Outputs
The stack outputs include:

- Public IP of the Jumpbox.
- Private IPs of the server and worker nodes.
- You can retrieve them using:

```
aws cloudformation describe-stacks --stack-name k8s-cluster-with-vpc --query "Stacks[0].Outputs"
```

## Start and Stop Instances
To save costs you can stop the instances when not in use and restart them afterwards.
```
./start-instances.sh
```
```
./stop-instances.sh
```

## Cleanup
To remove the stack and its resources:
```
aws cloudformation delete-stack --stack-name k8s-cluster-with-vpc
```

## User
Debian images run with the user `admin` and you need to execute some commands with sudo.

## Cost
I was able to complete the guide for less than 1 USD.

## Notes
The provided CloudFormation template is a simplified setup for learning purposes and should not be used in production environments without additional security measures.
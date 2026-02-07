# Manual Setup Guide

This document outlines the configuration steps performed in the AWS Management Console.

## 1. VPC & Network Configuration
* **VPC Name:** `sage-lab-vpc`
* **CIDR Block:** `192.168.0.0/20` (4096 IPs)
* **Tenancy:** Default

### Subnets
| Name | CIDR | Type |
|------|------|------|
| `sage-public-subnet` | `192.168.1.0/24` | Public (IGW attached) |
| `sage-private-subnet` | `192.168.2.0/24` | Private (Isolated) |

## 2. Security Groups & ACLs

### Security Groups (Stateful)
* **Bastion SG:** Inbound SSH (22) from `My_Personal_IP`.
* **Private SG:** Inbound SSH (22) from `sg-bastion-id` (Security Group Reference, not IP).

> **CLI Reference:** The JSON files in the `examples/` folder can be used to apply these rules programmatically:
> ```bash
> aws ec2 authorize-security-group-ingress --group-id <YOUR_SG_ID> --cli-input-json file://examples/bastion-sg.json
> ```

### Network ACLs (Stateless)
* Kept at default (Allow All) for this lab.
* **Why:** In this specific architecture, strict Security Groups provided sufficient isolation. NACLs would be introduced if explicit subnet-level blocking (e.g., DDoS mitigation) was required.

## 3. VPC Endpoint (S3)
* **Type:** Gateway Endpoint.
* **Service:** `com.amazonaws.us-east-1.s3`.
* **Route Table Association:** Added to Private Route Table (adds prefix list route `pl-xxxx`).

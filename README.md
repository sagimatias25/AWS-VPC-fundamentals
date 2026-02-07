# AWS VPC Networking Fundamentals (Lab)

![AWS](https://img.shields.io/badge/AWS-Networking-orange?style=flat-square&logo=amazon-aws)
![Type](https://img.shields.io/badge/Lab-Manual%20Setup-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Educational-yellow?style=flat-square)

## Project Overview

This repository documents a hands-on laboratory exercise designed to implement core AWS networking concepts. 
The objective was to manually architect a secure, segmented network environment from scratch to understand the underlying infrastructure before transitioning to Infrastructure as Code (IaC).

> **Note:** This project utilizes "ClickOps" (Manual Console Configuration) deliberately for educational purposes.

## Architecture

```mermaid
graph TD
    User((Admin)) -->|SSH| IGW[Internet Gateway]
    
    subgraph Custom_VPC [Custom VPC: 192.168.0.0/20]
        IGW -->|Route Table| PublicSubnet
        
        subgraph PublicSubnet [Public Subnet]
            Bastion[Bastion Host]
        end
        
        subgraph PrivateSubnet [Private Subnet]
            PrivateServer[Internal Workload]
        end

        Bastion -.->|SSH Jump| PrivateServer
        PrivateServer -->|VPC Endpoint| S3Endpoint[S3 Gateway Endpoint]
    end
    
    subgraph AWS_Services [AWS Managed Services]
        S3Bucket[(S3 Bucket)]
    end

    S3Endpoint -.->|Internal Traffic| S3Bucket
```

## Repository Structure

* `docs/setup-guide.md`: Detailed step-by-step documentation of the configuration.
* `scripts/verify_connectivity.sh`: Bash script used to validate network isolation and S3 access.
* `examples/*.json`: Reference JSON structures for security groups.

## ⚖️ Production Considerations (The "What Ifs")

This lab implements a **Single-AZ** architecture for simplicity. In a real-world production environment, the following changes would be mandatory to ensure High Availability (HA) and resilience:

1.  **Multi-AZ Deployment:** Mirroring the Public/Private subnets across at least 2 Availability Zones (e.g., `us-east-1a` and `us-east-1b`) to survive a data center failure.
2.  **Load Balancing:** Implementing an Application Load Balancer (ALB) in the Public subnets to distribute traffic.
3.  **Auto Scaling:** Replacing standalone EC2 instances with Auto Scaling Groups (ASG) for self-healing.
4.  **NACLs (Network ACLs):** Utilizing Stateless NACLs as an additional defense layer at the subnet boundary (e.g., for blocking specific malicious IP ranges), essentially acting as a firewall for the subnet itself.

---

## Author

**Sagi Matias** ([@sagimatias25](https://github.com/sagimatias25))

Part of my DevOps learning journey.
**Status:** Completed (Feb 2026) | **Next Step:** Converting to Terraform

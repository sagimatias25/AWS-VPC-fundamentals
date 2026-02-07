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

## 2. Routing Logic
1. Created an **Internet Gateway** (`sage-igw`) and attached it to the VPC.
2. **Public Route Table:** Added route `0.0.0.0/0` -> `sage-igw`.
3. **Private Route Table:** No internet route. Only local VPC traffic allowed.

## 3. Security Groups
* **Bastion SG:** Inbound SSH (22) from `My_Personal_IP`.
* **Private SG:** Inbound SSH (22) from `sg-bastion-id` (Security Group Reference, not IP).

## 4. VPC Endpoint (S3)
* **Type:** Gateway Endpoint.
* **Service:** `com.amazonaws.us-east-1.s3`.
* **Route Table Association:** Added to Private Route Table (adds prefix list route `pl-xxxx`).

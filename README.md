## 🚀 DevOps VPC Project: Secure Multi-Tier Infrastructure

### 🎯 Project Goal

Design and implement a production-ready VPC that supports DevOps workloads with:

* Network isolation
* Public & private subnets
* Secure access
* CI/CD-ready architecture
* Best practices (routing, security, NAT, logging)

### 🧪 PART 1: Architecture Overview

```bash
VPC (10.0.0.0/16)
│
├── Public Subnet (10.0.1.0/24)
│   ├── Bastion Host
│   ├── NAT Gateway
│
├── Private App Subnet (10.0.2.0/24)
│   ├── Application EC2 / Containers
│
├── Private DB Subnet (10.0.3.0/24)
│   ├── Database (RDS / VM)
│
├── Internet Gateway
├── Route Tables
├── Security Groups
└── VPC Flow Logs
```

### 🧪 PART 2: Step-by-Step Implementation

### 🔰 STEP 1: Create VPC
```bash
Name: devops-vpc
CIDR: 10.0.0.0/16

* Enable:

  * DNS Resolution
  * DNS Hostnames
```

### DevOps Purpose:
Provides isolated network boundary for environments (dev/stage/prod).

### 🔰 STEP 2: Create Subnets

### Public Subnet
```bash
Name: public-subnet
CIDR: 10.0.1.0/24
Auto-assign public IP: ✅
```

### Private App Subnet
```bash
Name: private-app-subnet
CIDR: 10.0.2.0/24
```
🚫 Do NOT enable public IP

### Private DB Subnet
```bash
Name: private-db-subnet
CIDR: 10.0.3.0/24

No public IP
```
### 🧠 DevOps Concept: Network segmentation & blast-radius control

* Public subnet
→ Exposed only where required

* Private App subnet
→ No direct internet access
→ Only reachable via LB / NAT

* Private DB subnet
→ Maximum isolation
→ Only app layer can reach DB

🔥 If one layer is compromised, others stay protected.

### 🔰 STEP 3: Internet Gateway

* Create IGW
* Attach to VPC

Note:
- Used only by public subnet
- ⚠️ Private subnets will NOT use this directly.

### Important Clarification
```bash
🔴 IGW is NOT attached to a subnet directly

✔️ IGW is attached to:

VPC

✔️ Subnets use IGW via:

Route Tables
```
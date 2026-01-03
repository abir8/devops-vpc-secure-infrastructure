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
```bash
devops-igw
```
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
### 🔰 STEP 4: Route Tables
Create TWO route tables:

1️⃣ Public Route Table
```bash
0.0.0.0/0 → Internet Gateway
```
Associate with Public Subnet

2️⃣ Private Route Table
```bash
0.0.0.0/0 → NAT Gateway
```
Associate with Private App & DB Subnets


### 🟢 PART A: Public Route Table

Allow public subnet to access the internet via Internet Gateway (IGW).

1️⃣ Create Public Route Table

1. Go to AWS Console → VPC
2. Left menu → Route Tables
3. Click Create route table
```bash
Fill values:

Name: public-rt
VPC: devops-vpc
```
4. Click Create route table


2️⃣ Add Internet Route (0.0.0.0/0 → IGW)

1. Select public-rt
2. Go to Routes tab
3. Click Edit routes
4. Click Add route

Set:
```bash
Field	                   Value
====================================
Destination	           0.0.0.0/0
Target	Internet Gateway → devops-igw
```
5. Click Save changes

3️⃣ Associate Public Subnet


1. Select public-rt
2. Go to Subnet associations
3. Click Edit subnet associations

Select:
```bash
public-subnet (10.0.1.0/24)
```
4. Click Save associations

✅ Public subnet is now internet-enabled.

### 🔵 PART B: Private Route Table

⚠️ Important
CANNOT add NAT Gateway route until NAT Gateway exists.

So this part is 2-stage.

1️⃣ Create Private Route Table

1. Go to Route Tables
2. Click Create route table

Fill values:
```bash
Name: private-rt
VPC: devops-vpc
```

3. Click Create route table

2️⃣ Associate Private Subnets

1. Select private-rt
2. Go to Subnet associations
3. Click Edit subnet associations

Select:
```bash
private-app-subnet (10.0.2.0/24)
private-db-subnet  (10.0.3.0/24)
```
4. Click Save associations

✅ Private subnets are isolated (no internet yet).
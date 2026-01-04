## 🚀 DevOps VPC: Secure Multi-Tier Infrastructure (AWS)

### 🎯 Project Goal

Design and implement a production-ready VPC that supports DevOps workloads with:

    - Network isolation
    - Public & private subnets
    - Secure access
    - CI/CD-ready architecture
    - Best practices (routing, security, NAT, logging)

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

#### DevOps Purpose:
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

| Field       | Value                         |
|------------|-------------------------------|
| Destination | 0.0.0.0/0                     |
| Target      | Internet Gateway → devops-igw |


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

### 🔰 STEP 5: NAT Gateway (AWS – Step by Step)

#### 🎯 Purpose (DevOps Context)

* Private subnets cannot have public IPs → they cannot access the internet directly.
* NAT Gateway allows outbound-only internet access while keeping instances private and secure.

Example Use Cases:

* Pull Docker images from Docker Hub
* Install OS updates/patches
* Access external APIs

1️⃣ Allocate an Elastic IP

1. Go to AWS Console → VPC → Elastic IPs
2. Click Allocate Elastic IP address
3. Select Amazon pool → Click Allocate
4. See the new Elastic IP (EIP), note it down.

This EIP will be used by NAT Gateway.

2️⃣ Create NAT Gateway

1. Go to AWS Console → VPC → NAT Gateways
2. Click Create NAT Gateway
3. Fill fields:

| Field                  | Value                                   |
|------------------------|----------------------------------------|
| Name tag               | `nat-gateway-devops`                    |
| Subnet                 | `public-subnet` (10.0.1.0/24)          |
| Connectivity type      | Public                                 |
| Elastic IP allocation ID | (select the one you just created)      |

4. Click Create NAT Gateway
5. Wait for status to show Available

3️⃣ Update Private Route Table

1. Go to Route Tables → private-rt
2. Click Routes → Edit routes
3. Add route:
```bash
Destination	Target
0.0.0.0/0	NAT Gateway → nat-gateway-devops
```
4. Click Save routes

Private subnets now have outbound internet access via NAT.

#### ✅ Verification

1. Launch an EC2 in private-app-subnet without public IP
2. Connect via bastion host in public subnet
3. Test outbound access:
```bash
ping google.com
```

or, pull Docker image:
```bash
docker pull nginx
```

It should succeed.

### 🔰 STEP 6: Security Groups (AWS – Full Implementation)

We will create **three Security Groups** for secure communication in our VPC.


#### 1️⃣ Bastion Security Group (`bastion-sg`)

**Purpose:**
- Public-facing jump host to SSH into private instances
- Protects private subnets from direct internet exposure

**Rules:**

| Direction | Type | Protocol | Port Range | Source / Destination      |
|-----------|------|----------|------------|--------------------------|
| Inbound   | SSH  | TCP      | 22         | Your IP (`x.x.x.x/32`)   |
| Outbound  | All  | All      | All        | 0.0.0.0/0                |

✅ **Attach this to Bastion EC2 in `public-subnet`**


#### 2️⃣ App Security Group (`app-sg`)

**Purpose:**
- For application / API servers in `private-app-subnet`
- Accept traffic only from Bastion / Load Balancer
- Can reach DB

**Rules:**

| Direction | Type       | Protocol | Port Range | Source / Destination               |
|-----------|------------|----------|------------|----------------------------------|
| Inbound   | SSH        | TCP      | 22         | `bastion-sg` (select by SG ID)  |
| Inbound   | HTTP       | TCP      | 80         | Load Balancer SG (or 0.0.0.0/0) |
| Inbound   | HTTPS      | TCP      | 443        | Load Balancer SG (or 0.0.0.0/0) |
| Outbound  | Custom TCP | TCP      | 3306 / 5432 | `db-sg`                        |

✅ **Attach this to EC2 instances in `private-app-subnet`**


#### 3️⃣ DB Security Group (`db-sg`)

**Purpose:**
- For database servers in `private-db-subnet`
- Only accessible by App servers
- No public access

**Rules:**

| Direction | Type        | Protocol | Port Range | Source / Destination |
|-----------|------------|----------|------------|-------------------|
| Inbound   | MySQL/Postgres | TCP    | 3306 / 5432 | `app-sg`          |
| Outbound  | All        | All      | All        | 0.0.0.0/0 (optional for updates) |

✅ **Attach this to RDS / DB EC2 in `private-db-subnet`**  
❌ No public access



#### 🔄 DevOps Concept / Blast Radius Control

- **Bastion SG:** Only you can SSH → audit & control access  
- **App SG:** Can only communicate with DB and LB → prevents lateral attacks  
- **DB SG:** Only App can reach DB → isolates data layer  

This setup follows the **least privilege principle** and **multi-tier architecture** for secure DevOps deployments.



✅ **Resulting VPC segmentation:**

| Subnet                  | Components / Access                          |
|-------------------------|---------------------------------------------|
| Public Subnet           | Bastion host + NAT Gateway + Internet       |
| Private App Subnet      | App servers, reachable via Bastion / LB    |
| Private DB Subnet       | DB servers, isolated, app-only access      |


### 🔰 STEP 7: Deploy Instances (AWS – Step by Step)

We will deploy **3 types of instances** in their respective subnets.



#### 1️⃣ Bastion Host (Jump Server)

**Purpose:**
- Public-facing SSH access to private subnets
- Acts as a jump host

**Deployment Steps:**

1. Go to AWS Console → EC2 → Instances → Launch Instances
2. Choose AMI:  
   `Ubuntu Server 24.04 LTS` (or `Amazon Linux 2`)
3. Instance type: `t3.micro` (or as per requirement)
4. Network:
   - **VPC:** `devops-vpc`
   - **Subnet:** `public-subnet`
   - **Auto-assign Public IP:** ✅ Yes
5. Security group: `bastion-sg`
6. Key pair: Choose existing or create a new key pair (`.pem`) for SSH
7. ✅ Launch instance



#### 2️⃣ App Server (Docker / CI Agents / API)

**Purpose:**
- Hosts apps, APIs, Docker containers, CI/CD agents
- Resides in private subnet for security

**Deployment Steps:**

1. Launch EC2 instance
2. Network:
   - **VPC:** `devops-vpc`
   - **Subnet:** `private-app-subnet`
   - **Auto-assign Public IP:** ❌ No
3. Security group: `app-sg`
4. Key pair: Same as Bastion (for SSH via jump host)
5. Optional: Attach IAM Role if app needs AWS access (S3, ECR, etc.)
6. Access app server via Bastion host:

```bash
ssh -i bastion-key.pem ubuntu@<bastion-public-ip>
ssh -i app-key.pem ubuntu@<private-app-ip> # from bastion
```
#### 3️⃣ Database Server (RDS or EC2)

**Purpose:**  
- Database layer, completely private  
- Only reachable from App SG  



#### 🔹 Deployment Options 🔹
#### Option A: RDS (Managed DB)

Steps:

1. Go to **RDS → Databases → Create Database**
2. Configure the following:

| Field                | Value                     |
|----------------------|---------------------------|
| Engine               | MySQL / PostgreSQL        |
| VPC                  | devops-vpc               |
| Subnet               | private-db-subnet        |
| Security group       | db-sg                    |
| Public accessibility | ❌ No                     |
| Credentials          | Set username/password     |



#### Option B: EC2 Database

Steps:

1. Launch an EC2 instance in **private-db-subnet**  
2. Assign security group: **db-sg**  
3. **No public IP**  
4. Install database manually:

```bash
# MySQL example
sudo apt update
sudo apt install mysql-server

# PostgreSQL example
sudo apt update
sudo apt install postgresql postgresql-contrib
```

### 🔰 STEP 8: Enable VPC Flow Logs

* Destination: CloudWatch Logs / S3
* Capture: ALL traffic

DevOps Value:

* Network debugging
* Security auditing
* Compliance

### 🔰 STEP 9: DevOps Use Case Integration

This VPC supports:

* Jenkins / GitHub Actions runners
* Kubernetes worker nodes
* Monitoring agents
* AI / ML workloads
* Secure API hosting

## 🧪 PART 3: GitHub Repository Structure
```bash
devops-vpc-project/
├── diagrams/
│   └── vpc-architecture.png
├── terraform/        # (optional future)
├── scripts/
│   └── bastion-setup.sh
├── README.md
```




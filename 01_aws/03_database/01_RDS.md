- https://chatgpt.com/c/675945a8-f8b8-800d-a789-e07e6db38e8d
--- 
- **AWS RDBMS offering** 
  - Option-1 : `on EC2`
    - Provision Ec2
    - install RDBMS and maintain it (os patching, security update, etc)
  - Option-2 : AWS `Aurora`
  - **Option-3** : AWS `RDS` 

---
# RDS 
## Intro
- not serverless
- **regional**
- RDBMS | OLTP
- migrate to Aurora :point_left:
  - involves significant systems administration effort
- 2 options: custom + fully manages

---
## RDS :: custom :yellow_circle:
- RDS **does not** allow you to access the host OS of the database
  - use **RDS custom** 
  - allow some customization capabilities of underlying DB and **OS** (limited)  :dart:
  - only for `SQL server` and `oracle` DB.
  - First disable automation mode, take snapshot, then access it.
  
---  
## RDS :: fully managed :green_circle:

- Automates  below **administrative tasks** :

### 1. hardware provisioning
- choose **EBS volume type**:
  - `gp2`
  - `io1`
- choose **RDS ec2 instance s** : 
  - compute family size
  - no access/ssh
    
  
### 2. database setup 
- choose **Supported engine**:
  - Postgres, MySQL, MariaDB, Oracle, Microsoft SQL Server, IBM DB2
  - Aurora (AWS Proprietary database, not open source)

### 3. High Availability
- choose **availability**
  - setup **single-AZ** (default) 
  - setup **mutli-AZ**
    - fault tolerance
    - SYNC replication b/w instance in diff AZ. :dart:
- fact: Multi-AZ keeps the **same connection endpoint url** for all instance in AZ :point_left: 
- easily switch from Single-AZ to multi-AZ  :point_left:


### 4. patching
- Auto **OS patching** :: in maintenance window.
```text
- Scenario : in Mutli-AZ setup :dart:
  - a. primary and standby, both will upgrade at same time with downtime ? ****
  - b. first primary, then standby. no downtime ?
  - c. first standby, then primary. no downtime ?
```

- Running a DB instance as a Multi-AZ deployment can further **reduce the impact of a maintenance** :point_left:
  ```text
  - Perform maintenance on the standby.
  - Promote the standby to primary.
  - Perform maintenance on the old primary, which becomes the new standby.
  ```
---
### 5. Scalability
#### instance::scale (vertical)
- Scaling involves resizing instances
- which may require **downtime**.

#### instance::scale (horizontal) - read replica
- Not built-in scaling 
  - but can manually create - `ASG` and `CW:alarm` on these `metric`:
    - connection count 
    - cpu utilization
    - READ/WRITE traffic
    - ...
  - or, manually create read replication anytime.

- **READ replica**
  - each Read Replicas add **new endpoints URL**, with their own DNS name :point_left:
    - use case: 
      - analytics application
      - can run **Analytics**
  - each Read Replica is associated with a **priority tier (0-15)**. :dart: :dart:
    - In the event of a failover, Amazon Aurora will promote the Read Replica that has the **highest priority**.
    - If two or more Aurora Replicas share the same priority, then Amazon RDS promotes the replica that is **largest in size**
    - eg:  tier-1 (16 terabytes), **tier-1 (32 terabytes)**, tier-10 (16 terabytes), tier-15 (16 terabytes), tier-15 (32 terabytes)
  - Also, can promote as primary in DR, if stand-by not provisioned.

#### **Underlying Storage**
- define: 
  - **threshold** ( maz-size in GB ) 
  - **trigger**  eg: free space < 10%, space runs last 5min, etc.
- good for unpredictable workloads

---
### 6. DR support
#### option-1: PITR 
- Point in Time Restore 
- Continuous backups happens and goes to s3
- can retore these backup to new database instance.

#### option-2: Stand-by replica
- manually enable Multi AZ-setup for DR. 
- master-writer-DB (az-1) --> `SYNC replica/free` --> Stand-by-DB (az-2)
- **Automatic fail-over** from master to standby in DR situation. :dart
  - R53 **CNAME** record will be updated to point to the standby database. :dart:
  ```
    - R53 failover-record for RDS url1. 
      - url1 -x-> primary/active
      - url1 --active--> secondary/passive 
  ```
#### option-3: Promote Read replica
- **cross-region-read replicas**, is also possible : paid
- promote any READ replica as main DB later based on priority and size

---
### 7. Security
#### Encryption
- `At-rest` encryption:
  - Database master & replicas encryption using AWS KMS
  - If the master is not encrypted, the read replicas cannot be encrypted
  - To encrypt an un-encrypted database, go through a DB snapshot & restore as encrypted
  - can only enable encryption for an Amazon RDS DB instance when you create it, not after the DB instance is created :dart:
- `In-flight` encryption: 
  - TLS-ready by default, use the `AWS TLS root certificates` client-side.
  - use the same `domain-name-1` for both the certificate and the CNAME record in Route 53.
  - Export cert in ACM 
  - when create/modify RDS instance, configure it use custom  cname `domain-name-1`.
- RDS support **TDE** (transparent Data encryption) with Oracle  and SQL :dart:
  - integrated with **CloudHSM** (store keys in single tenant hardware module.) [10_HSM_DVA.md](../06_Security/10_HSM_DVA.md)
  - key managed by AWS
  - automatic Encryption/decry..
  
#### IAM Authentication :dart:
  - works with MySQL and PostgreSQL :point_left:
  - token has a lifetime of `15 minutes`
  - can use `IAM roles` to ec2-i, to connect to your database (instead of username/pw). eg:
    - ecs (role-1) --> rds
    - lambda (role-1) --> rds
  - or, create one time `password/token` after cluster creation

#### Security Groups
- Control Network access to your RDS / Aurora DB

---
### 8 DB backup
- for **automatic** bkp , retention 1 to 35
- for **manual**, retention - as long we want for maul backup.
- on-prem MySQL/postgres DB --> create db-dumps( `Percona XtraBackup`) --> place in S3 --> then restore.
- with automated backups, I/O activity is no longer suspended, since backups are taken from the standby :dart:

### 9 cloning
- faster than backup > restore
- uses `copy-on-write` - use same volume + for new changes additional storage allocated and data copied to it.
- use case: create test env from prod instance.

---
## 4. more
###  4.1 RDS proxy
- pools open connections.
- reduces fail-over time by 66%
- access privatey only
- client --> RDS proxy --> RDs instance
- ![img.png](../99_img/db/img_5.png)

### 4.2 performance
- Uses SSD-based storage.
- `write instance DB` + `Read replica/s` for improved read performance.
- **Up to 15 READ replica/s**
  - within AZ, or
  - cross-AZ, or
  - cross-region (paid replication)
- main-DB --> `A-SYNC replication (free within region)` --> Read Replicas

### 4.3 RDS::pricing
- Charged based on instance class and storage used.
  - standby instance
  - read replica
- inbound data transfer is free.
- Outbound data transfer is charged based on the volume of data transferred outside of AWS
- **replication charge**: `cross-region only` :dart:

- **Cost Optimization Tips**
  - Use Reserved Instances: Commit to a 1 or 3-year term for discounts
  - Enable Auto-Scaling.
  - Choose the Right Storage.
  - take snapshot and delete db if you dont need. later on restore from snapshot. this will save money.

### 4.4 Integration with AWS Ecosystem
- IAM, Lambda, CloudWatch, and Elastic Beanstalk.
- Simplifies building serverless or event-driven architectures

--- 
## 5. demo
```
- create single DB RDB in region-1
- choose underlying ec2 type (memory optimzed), EBS volume
- DB admin + password + DB name
- backup/screenshot : 
  - enable + retention policy upto 35 days
  - backup window preferrence.
- enable STORAGE autoscaling, give maz size : 100 GB
- Connectivity : 
  - option-1: add "specified ec2-i", will automatically configure things (good for beginner)
  - option-2: Dont connect to Ec2-i
    - define VPC, subnet
    - allow public access
    - choose SG
    - port 
- Authentication : DB password or IAM
- Monitoring : Enable
- backup window pr
- Miantaincence window
- Enable deletion prevention 

 === READY to USE ===
 
- Check monitoring dashboard : CPU, Moemory, Connections, etc
- action:
  - create read replica
  - take Snapshot + migrate Snapshot + restore to point.
  - create read replica.
 
```
---
## 99. for DVA
![img.png](../99_img/dva/kms/05/imgrds.png)

## 100. exam
-  un-encrypted RDS, encrypt it:
  - take screenshot >> encrypted snapshot >> restore it as new DB : correct
  - take screesnhot >> encrypted while restoring :x:

- **PITR** more
  - Takes an automatic **daily** snapshot (called a daily backup).
  - Continuously backs up transaction logs every `5 minutes` to allow point-in-time recovery within the backup retention period.
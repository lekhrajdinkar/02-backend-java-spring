# DR
- D : event that has a negative impact on a `company’s business continuity` or `finances`
- DR : `preparing` for and recovering from a disaster.
  - On-premise => On-premise
  - On-premise => AWS Cloud: hybrid recovery
  - AWS Cloud `Region A` => AWS Cloud `Region B`
---
## A. Key terms
- `RPO`: Recovery `Point` Objective
  - taking backup in one hr, so if D happens, then can take restore from backup/point taken an hr ago.
  - so rpo is 1hr here.
  - 1 min is expensive than 1 hr
  
- `RTO`: Recovery `Time` Objective
  - D happened, it took 2 hour to recover.
  - there was downtime of 2 hr
  - 15 min is expensive than 2 hr.
  
- `low` RPO/RTO === `expensive`

![img.png](../99_img/dr/dr-1/img.png)

---
## B. `Strategies` to optimize RPO/RTO

### B.1 backup / restore
- DB:
  - RDS (single-region) --> 1hr --> backup/snapshot --> S3(not directly accessible) in  same region (az-1 and az-2)
  - DR happens > az-1 goes down.
  - recreate infra using IAC + R53
  - or recover db from s3 snapshot (az-2 must have it)
  - if region has outage.
    - use cross region replication for rds
    - or use Aurora --> have read Replica/s in other region 
    - or use global aurora -->  have read Replica/s in other region ( < 1 sec)
    - and promote aurora read replica as primary in DR.
- have your IAC ready, run it on DR
- code/app deploy : take AMI + docker images
- RTO is high, since getting up whole thing from scratch.
- RPO is 1hr here.

![img_1.png](../99_img/dr/dr-1/img_1.png)

### B.2 Pilot light
- A `small version of the app` (critical business workload) is always running in different region.
- update r53 to switch, on DR.
- continuously replicate critical db to this region.

![img_2.png](../99_img/dr/dr-1/img_2.png)

### B.3 warm light
- Full but `scaled-down version` of your system, up and running in different region
- Upon disaster, just `scale up` to `production load`

### B.4 multi site
- `active - active`
- Full Production Scale is running AWS and On Premise
- on D, it will inactive - active.
- no recovery need to do.
- RTO is in second/min
- expensive

![img_3.png](../99_img/dr/dr-1/img_3.png)

![img_4.png](../99_img/dr/dr-1/img_4.png)

---
## C. DR tips
- same we have learnt so far. nothing new.

- `Backup`
  - EBS Snapshots, RDS automated `backups` / Snapshots, etc…
  - Regular pushes to S3 / S3 IA / `Glacier`, Lifecycle Policy, `Cross Region Replication`
  - From On-Premise: `Snowball` or `Storage Gateway`
  
- `High Availability`
  - Use `Route53` to migrate DNS over from Region to Region
  - RDS `Multi-AZ`, ElastiCache Multi-AZ, EFS, S3
  - `Site to Site VPN` as a recovery from `Direct Connect`
  - Use `ASG`, ALB

- Automation
  - `CloudFormation` / Elastic Beanstalk to re-create a whole new environment
  - `Reboot EC2 instances` with CloudWatch if alarms fail
  - AWS `Lambda`  to automation to build infra, etc
  - `IAC` / terraform

---
# Cloudtrail 
## 1. Intro
- enabled by default
- Provides **governance, compliance and audit** for your AWS Account.
  - captures all Account `logs` and `Cloudtrail:events` 
    - `90 days` default **retention**
    - for further analysis/investigation,
      - log/event >>  s3 >> athena
- eg: 
  - DynamoDB table create API called --> logged in CT + event sent to `eventBridge`,
  - similar endless API calls. 

- ![img_1.png](../99_img/decouple/ct/img_1.png)


---
## 2. Cloudtrail : events

### `Data Events` 
- (on/off)
- Operations on **resources data**
- eg: 
  - Amazon `S3 object-level activity` (GetObject, DeleteObject, PutObject,etc)

### `Management Events` 
- (on) : cannot disable :point_left:
- Operations on **resources**
- eg:
  - Configuring security (IAM AttachRolePolicy)
  - Configuring rules for routing data (Amazon EC2 CreateSubnet)
  - Setting up logging (AWS CloudTrail CreateTrail)
- **Management Read Events** 
- **Management Write Events**
  

### `insight Events` 
- (on/off)
- Management-Events -->  `CT:Insight > (analyze and generate)` --> insight-Events
- **event for unusual activity**
- eg: 
  - inaccurate resource provisioning
  - hitting service limits
  - Bursts of AWS IAM actions
  - Gaps in periodic maintenance activity
- ![img_2.png](../99_img/decouple/ct/img_2.png)

## 3. Architecture Example:
- ![img_3.png](../99_img/decouple/ct/img_3.png)
- ![img_4.png](../99_img/decouple/ct/img_4.png)






- https://chatgpt.com/c/6761df7b-aa90-800d-b11f-c0e411c511fe
--- 
# API gateway (Serverless)
## A. Intro
- **API** ( `REST API`** , `http API` ,`websocket API`), with other benefit:
  - **caching**
  - API **versioning** : enable
  - API **documentation** : enable SDK/doc generation
  - **interceptor** : `mapping template` to transform req/resp (json/xml only)
  - more:
    - **No infrastructure** to manage. :)
    - create **environment**  - dev,qa,prod
    - **throttling** - rate limiting
      - has default setting to prevent from DDoS :dart:
    - **security** - check below.
    - **import**
      - already have pre-define API
      - from Swagger/OpenAPI
      - req/resp body schema validation
---
## B. API gateway: integration :books:
### B.1. **Backend**
- can have **multiple backend** and create **forwarding/transformation rule** at api-gateway level as well. :point_left:
  - use it **gateway for microservice**
- API-g >> PROXY >>**lambda** (event,context)
  - pure serverless
  - most common
  - default/max timeout : `29 sec` :point_left:
  - use **AWS_PROXY**
    
- API-g >> PROXY >> **Any HTTP backend**
  - API-g >> **on-prem-API**
    - DX or S2S connection.
  - API-g >> **ALB**
    - expose ALB public directly. happening in ccgg.
    - expose API-g >> ALB > tg [ecs/eks - `container` - ec2/fargate]
      
- API-g >> PROXY >> **`Any` AWS service API call.**  
  - s3:*
  - sqs:getMessage
  - kds:* :point_left:
  - ...
  - note: setup **mapping template** :point_left:

---    
### B.2. **Proxy**
- there are 3 proxy options. choose either.
#### B.2.1. AWS_PROXY 
- NO mapping template
- **request/response object** uses inbuilt aws-template
- eg: **API-g <==>    `AWS_PROXY`  <==> lambda**
- ![img_1.png](../99_img/dva/api-g/02/img_1.png)
- Note: 
  - **ALB <==>         `AWS_PROXY` <==> tg:lambda**
  - use same template, remember
  - [01_ELB_ASG.md](../01_compute/01_ASG.md)

#### B.2.2. HTTP_PROXY
- NO mapping template
- eg: **API-g <==>  AWS_PROXY  <==> http-backend (`ALB`)**
- ![img_4.png](../99_img/dva/api-g/02/img_4.png)

#### B.2.3. NO PROXY for (HTTP / AWS)
- set up mapping template
  - **Content-Type** must be == application/json/xml
- ![img_2.png](../99_img/dva/api-g/02/img_2.png)

#### B.2.4. MOCK
- for dev/testing purpose

---
### B.3.  Mapping Template
- response from lambda
  - ![img.png](../99_img/dva/api-g/03/img.png)
- create template
  - ![img_1.png](../99_img/dva/api-g/03/img_1.png)
- check final response
  - ![img_2.png](../99_img/dva/api-g/03/img_2.png)
  
#### Use-cases
- **use-case-1**: transform SOAP response
  - ![img_3.png](../99_img/dva/api-g/02/img_3.png)
- **use-case-2**: tranform query param
  - ![img_5.png](../99_img/dva/api-g/02/img_5.png)

---  
## C. Endpoint type
- by **Deployment model** 
### 1 `regional`
- deployed in single region eg: us-west-1
- **for users in one region**
- can have **regional with CloudFont** eg:
  - set-1: for us-west-1
  - UNION
  - Set-2 : create CF distribution-1 (CF) : whiteList - europe user + india user

### 2 `edge-optimized` (default)
- deployed/lives in one region, but configure to
  - route request through CF many edge location/s
  - backed by : cloudFront distribution
- **for global user**

### 3 `private`
- with private VPC
- API-g >> **VPC endPoint**

---
## B. Security : REST API-gateway
- no native support for openIDConnect/OAuth - `REST API-gateway`
- but `Http API-gateway` has it.

### 1. Authentication
#### 1.1. API keys
- **Authentication**
  - pass`x-api-key` header

    
---    
#### 1.2 IAM
- ![img_1.png](../99_img/dva/api-g/04/img_1.png)
- for IAM user / roles
  - **IAM-based SigV4 signing** 
  - AWS SDKs and AWS CLI handle SignatureV4 signing automatically.

#### 1.3 Cognito
- for global user
  - integrate with 3rd party ID provider.
  - ![img_2.png](../99_img/dva/api-g/04/img_2.png)

#### 1.4 Lambda Authorizer
![img_3.png](../99_img/dva/api-g/04/img_3.png)
- Great for 3rd party tokens
- Handle Authentication verification + Authorization in the Lambda function

### 2 SSL
- export certificate to **ACM**
- create **R53** entry (cname/alias)
  - integrated with ACM
  - keep certificate it `us-east-1` for edge-optimized endpoint.
  - certificate with backend server domain name.

### 3 CORS
- CORS can be enabled on api gateway
- ![img.png](../99_img/dva/api-g/04/img.png)

### 4 Authorization
  - API-gateway **resource iam policy**, 
    - not exist by default. have to create one :dart:
  - principle/who:
    - use for **cross account id**
    - ...
    
### 5 **`throttle` setting** for stage
- set **rate** (no.of req per seconds make be made)
  - `10000 rps `across all APIs :point_left:
  - set limit for stage. :point_left:
  - else one api/stage will consume all and impact other
- set **burst** (no of concurrent request)

### 6 **`firewall` setting** for stage
- set WAF
- set certificate

### 7. create usage plan
- first create API key

---
## C. pricing :books:
```text
REST API
    $3.50 per million requests (first 300M, then $1.51 per million).
    Data transfer & caching costs extra.
    
HTTP API (Cheaper than REST API)
    $1.00 per million requests for first 300M, 
    then $0.90 per million
    
WebSocket API
    $1.00 per million messages 
     connection minutes cost.
```

---
## Y. hands on
```
- create (4 Type) : api-gateway-1
    - HTTP API  >> lambda, http backend
    - REST API | REST API (Private,vpc-1) >> lambda, http backend, awsServices
    - Web-scoketAPI  >> lambda, http backend, + awsServices
    
  - choose - REST API
  - API details:  
        - create new **
        - import frpm OPen/AI swagger
        - clone API
  - deplomnet model : regional 
        - region : us-east-1
  - integration Type: lambda
        - choose method: lambda-fn-1
        
  - set timeout : default 30 s
  
  - check lambda > permission > "resource based policy statemnet" 
    - allow invoke for agi-g          <<<<
        
  - proxy integration : enabled       <<<<                
    - if not enabled
    - then create mapping template
        
  - invoke from aws webcosole
  
  - Deploy API
      - choose stage - dev,qa, prod
      - will get invoke URL
      - try on BROWSER
```

---
## Z. Architecture Example
- ![img.png](../99_img/moreSrv/api-gateway/img.png)
- ![img_1.png](../99_img/moreSrv/api-gateway/img_1.png)
- ![img_1.png](../99_img/dva/api-g/01/img_1.png)
### microservice (gateway)
![img.png](../99_img/dva/api-g/05/img.png)

- https://developer.hashicorp.com/terraform/tutorials/configuration-language

--- 
# HCL ( HashiCorp Configuration Language)
## A. basic
- used write `configuration` - to create infra.
- .tf, .tfvar, etc
- **String-interpolation** 
  - `web-sg-${var.resource_tags["project"]}-${var.resource_tags["environment"]}`
- write in JSON or yaml
- `state file` / `terraform.tfstate` - keep it secure and encrypted.

## B. project structure 
  - `terraform { ... required_version="", required_provider={} }`
  - can make declaration anywhere. But its good practice to have seperate files.
  - keep them in same-folder (`root-module`)
  - every Terraform configuration is part of a module
  ```
    - root module:
        - main.tf
        - backend.tf - org, `TF_CLOUD_ORGANIZATION`=org1
        - variable.tf
        - provider.tf
        - dev.qa,prod.`tfvars`
        - s3-resource.tf, sqs-resource.tf, etc
        - output.tf
        - /directory-1/
                child-module-1/
                ├── main.tf
                ├── variables.tf
                ├── outputs.tf
        - /directory-2/child-module-2.tf
        
        ** root-module can use other module's config file
  ```
---
## C. Language constructs
### provider
- aws : https://registry.terraform.io/providers/hashicorp/aws/latest
  - aws_`key_pair`
  - aws_`security_group`
  
### variable  (32 char max)
- types  - number, string, list, map, bool, tuple, object 
- use : var.*
- replace default value:  
  - `terraform apply -var var1=val1`
  - `terraform apply -var-file var1=val1.tfvar`
- `validation` { condition=, error_message=}
- sensitive = true :
  - apply will prompt to enter values 
  - or can provide via `.tfva`r file too.
    
### output
- sensitive = true : will not be printed on logs.
- `terraform output` -> query : output1, json, etc

### `locals` 
- locals { instance_count = var.environment == "production" ? 5 : 1 }
- name to complex expressions or repeated values
- making your configuration easier to read and maintain.
- sensitive = true : will not be printed on logs.
- use : local.*

### resource
- `attribute` : (optional, mandatory)
- `argument` : resourceType.resourceName.agrument.*
- Resource Lifecycle : ?
- Resource dependencies:
  - trf creates dependency graph.
  - `Implicit`, eg: ec1 > elasticIP , automatically infer by attribute
  - `Explicit` : certain scenario, need to tell explicitly using `deponds_on`
     - eg : depends_on = [aws_s3_bucket.r1, aws_instance.r1]
- `count`
  - Manage `similar resources` with count.
  - `replicates` the given resource with given count.
  ``` 
        eg: resource "aws_instance" "app" { count = 4 }
          - length(aws_instance.app) : 4
          - aws_instance.app : list of all instances.
          - aws_instance.app.*.id : list of ids
          - aws_instance.app[0] : first instance tr provisioned.
          - aws_instance.app[count.index] : current index, useful while iterate.
  ```
- `for-each` = var.projects # p1:{}, p2:{}, etc
  - on map : `each.key` and `each.value.?`
  - on list/set : `each.key`=index,  `each.value`=item
  - `key`(var.projects), `sort`(key(var.projects))
  - `value`(var.projects)
  - value = { for p in sort(keys(var.project)) : p => module.elb_http[p].elb_dns_name }
      
### variable set
- use variable across workspace/s.  

### Functions
- merge(), join(), count(), length(), sort(), key(), value()
- `templatefile`(tftpl-file-1, map), `file`(file-1)
- `lookup`(map,key) - like map1.get(k1) in java. 
- `file`()

### Terraform template
- .tftpl files
- used as templates for generating configuration-files/ other-text-files.
- `dynamically generate` files by substituting variables and expressions within the template.
- eg: 
    ```
    # user_date.tftpl >> shell script text file having lots of placeholders- ${placeholder-1}, etc
    user_data= `templatefile`("user_data.tftpl", { placeholder-1 = var.value1, placeholder-2 = var.value2 })
    ```

### expressions`
- ternary operation

---

## Z. More
```
client-webapp = {
      public_subnets_per_vpc  = 2,
      private_subnets_per_vpc = 2,
      instances_per_subnet    = 2,
      instance_type           = "t2.micro",
      environment             = "dev"
    },
    internal-webapp = {
      public_subnets_per_vpc  = 1,
      private_subnets_per_vpc = 1,
      instances_per_subnet    = 2,
      instance_type           = "t2.nano",
      environment             = "test"
    }
---
project-root/
├── config1/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
├── config2/
│   ├── main.tf
│   ├── variables.tf
|   ├── outputs.tf

- Each configuration (in config1/ and config2/) is independent of the other. 
- You need to run Terraform commands separately for each configuration.
- Each configuration will have its own state file.
- Resources defined in one configuration are not aware of resources defined in another configuration
---
ssh-keygen -C "your_email@example.com" -f ssh_key

resource "aws_key_pair" "ssh_key" {
  key_name = "ssh_key"
  public_key = file("ssh_key.pub")
}


```

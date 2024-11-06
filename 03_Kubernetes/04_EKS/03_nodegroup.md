## Nodegroup
- collection of nodes (virtual machines) within a cluster that share the same configuration. 
- Node groups make it easier to manage and scale the infrastructure that runs your Kubernetes workloads.

## Key Points 
-` Homogeneous Configuration`: 
  - All nodes within a node group have the same instance type, disk size, AMI (Amazon Machine Image), and other configurations.
  - This ensures consistency in the resources available to the workloads scheduled on these nodes.
- `Scaling`: 
  - Node groups can be scaled up or down based on the needs of your workloads. 
- `Workload Separation`: 
  - Separate different types of workloads (e.g., frontend, backend, batch processing) into different node groups
  - to ensure **optimal resource allocation** and **security isolation**.
- `Cost Optimization`: 
  - Use different instance types in separate node groups to optimize costs based on workload requirements. 
- `High Availability`: 
  - Spread node groups **across multiple availability zones** to ensure high availability and fault tolerance.
  
- In short, providing flexibility, scalability, and efficiency in handling diverse workload requirements.


```
aws eks create-nodegroup \
--cluster-name my-cluster \
--nodegroup-name my-nodegroup \
--subnets subnet-12345678 subnet-87654321 \
--instance-types t3.medium \
--scaling-config minSize=1,maxSize=10,desiredSize=2 \
--ami-type AL2_x86_64 \
--node-role arn:aws:iam::123456789012:role/EKSNodeInstanceRole
```




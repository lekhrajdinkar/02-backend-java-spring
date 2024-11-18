# references
- OIDC provider: with Okta `Dont use this`  <<<
    - https://dev-16206041-admin.okta.com/
    - https://dev-16206041.okta.com/
    - eks-cluster-app : https://dev-16206041-admin.okta.com/admin/app/oidc_client/client/0oal3d72smuSHBhwF5d7#tab-general
        - client_id : 0oal3d72smuSHBhwF5d7
        - issuer URI :
            - https://dev-16206041.okta.com/oauth2/default (default)
            - https://dev-16206041.okta.com/oauth2/ausl3dg4kkpyvEBft5d7
---  
# chatgpt:
- EKS 04 - Authentication + IRSA  : https://chatgpt.com/c/67342f43-7220-800d-8831-68fe91ea7a87
- EKS 02 - OIDC with okta : https://chatgpt.com/c/67341083-2714-800d-b4f6-6b52821c0181 `skip`
- EKS-03 - `ns:kube-system > configMap:aws-auth` : https://chatgpt.com/c/6734280e-7d48-800d-b410-280da79926fe
    - access  specific namespace based on iam-role-assumed-by-sa  <<<
    - eg: sa-1 > assumed role-1 > access ns-1
- EKS + harness pipeline - `handson`
  - https://chatgpt.com/c/67346f23-ce58-800d-9b35-a0ccf088f920
  - https://chatgpt.com/c/67352892-e094-800d-a053-9a51c1074097
  - https://chatgpt.com/c/67358116-3f1c-800d-96c6-c6d447f1b283

---
```

aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-id-from-output" --region us-west-2
aws ec2 describe-vpcs --vpc-ids vpc-id-from-output --region us-west-2
aws eks list-fargate-profiles --cluster-name your-cluster-name --region us-west-2
aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=vpc-id-from-output" --region us-west-2
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=vpc-id-from-output" --region us-west-2
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=vpc-id-from-output" --region us-west-2


aws eks describe-cluster  --name maps-outbound-us-west-2-dev2-eks-fargate-cluster --region us-west-2 --query "cluster.identity.oidc.issuer"
aws iam create-open-id-connect-provider --url https://oidc.eks.us-west-2.amazonaws.com/id/867FAFA03F6706024B5895223D5D3451 --client-id-list sts.amazonaws.co
aws eks get-token  --cluster-name maps-outbound-us-west-2-dev2-eks-fargate-cluster --region us-west-2
aws eks update-kubeconfig --name maps-outbound-us-west-2-dev2-eks-fargate-cluster --region us-west-2

aws eks describe-update --name maps-outbound-us-west-2-dev2-eks-fargate-cluster  --update-id 388626d9-068d-3325-b988-f15ecd94ee51 --region us-west-2
# got update it from trf logs

kubectl get configmap aws-logging -n kube-system
```

-https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html
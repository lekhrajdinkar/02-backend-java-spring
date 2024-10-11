# pod placement on node
## A. taint and tolerance
- has nothing with security.
- just to set restriction on pods must be scheduled on which pod.
- analogy :
    - person (node) - taint applied
    - and bug (pod) - tolerance applied.
- > k taint  nodes node1 taint1=blue:**taint-effect**
    - taint-effect : 
      - `NoSchedule` ** : new pod will not be scheduled + existing will **stay**.
      - `preferSchedule` : system will try **but not guaranteed**
      - `NoExecute` : new pod will not be scheduled + existing pod having no tolerations, will get be **evicted**
### Demo
  - Node - 1 (taint=blue:NoSchedule),2,3
    - > k taint nodes node1 taint1=blue:NoSchedule
  - pod - A, B, C, D
  - none of the pod got scheduled on Node-1, since no one is tolerant to Node-1.
  - next, add tolerance to pod-D for taint=blue.
    - pod spec > `tolerations`
    ```
    spec:
      tolerations: #array
      - key: "taint1"
        operator: "equals"
        value: "blue"
        effect: "NoSchedule"
        ## taint1 = blue : NoSchedule
      -
      -
    ```
  - only Pod-D will get scheduled to Node-1
  - NOTE: pod=D is tolerate to Node-1, but that does NOT mean, it will scheduled to only Node-1.
    - Pod A,B,C --> go to node 2,3
    - Pod D --> can go to Node 1,2,3 (all)
- fact-1 
  - master node is like worker node and can run pods.
  - but schedular nevers  assign any pod to master
  - becoz master has taint.
  - check this >>  k describe  node `kubemaster` | grep taint
  
---
## B. Node Selector
- scenario: want **POD-D** (big prcocess) to run only in **Node-1** (larger Node) (refer above demo)
- solution:
  - add label in Node
  - pod definition, use node-selector.
- pod spec > NodeSelector > label-1: value-1
- demo:
    ```
    - k label nodes node-1 size=large
    - pod:
        spec:
            nodeSelector: 
                size: large
                # this pod will go mnode-1 only.
    ```
---

## C. Node Affinity
- scenario: 
  - want pod-D to go Node-1(Large) `or` Node-2(Medium)
  - but `not` node-1(small)
-  affinity to handle some complex combination / expression
- demo:
    ```
    apiVersion: v1
    kind: Pod
    metadata:
    name: pod-d
    spec:
    containers:
    - name: nginx
      image: nginx
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution: #hard constraint - preferred
            nodeSelectorTerms:
              - matchExpressions:
               - key: size
                 operator: In
                 values:
                   - Large
                   - Medium
               - key: size
                 operator: NotIn #more - Exists
                 values:
                   - Small

    ```
- type:
  - `required`DuringScheduling `Ignored`DuringExecution
  - `preferred`DuringScheduling `Ignored`DuringExecution
  - `required`DuringScheduling `required`DuringExecution (planned for future) --> this will evict pod if expression/label change in b/w.
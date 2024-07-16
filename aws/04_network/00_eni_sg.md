# EC2: Network

## EC2: Network: ENI
- Attach `elastic network card` to Ec2 - `flexible`
- network fail-over :: if ec2-1 is down >> then launch ec2-2 and attach ENI from old instance to new.
- bound to AZ.

- contains/defines:
    - speed info, eg 10Gbps
    - `VPC` and subnet
    - one IP public + one MAC address.
    - one private (primary) + many secondary private IP
    - elastic IP
    - Security groups.

- > `elastic-IP` vs  ( random Public IP + DNS ) better vs ELB/LB
## EC2: Network: Security group
- virtual firewalls / traffic rules(60 max) - eg: allow incoming http, SSH traffic.
- inbound: all traffic blocked by default.
- outbound : all traffic allow by default

- `M2M` : apply multiple(max 5) sg on an ec2 instance, apply same sg2 to multipe ec2 insatnces.
    - EC2 instance-1 has sg-1, sg2,etc
    - EC2 instance-2 has sg-1, sg3,etc
- `region` specific ( sg + region combination )
- outside EC2
- `Stateful`
    - if inbound allows request is allowed, then response is allowed too with further checking rule.
    - unlike ACL (staeless):  inbound rule is checked > req allowed > response came > outbound rule is checked.
- always create new SG for `SSH` (22)
    - ssh -i "path/to/your-key-file.pem" -p 22 ec2-user@your-ec2-public-dns
    - use keypair over password
- inbound RULES:
    - Protocol (TCP, UDP, RDP etc)
    - `Source` IP range/CIDR + `another SG`
        - 203.0.113.1/32 (specfic IP)
        - 0.0.0.0/0 (anywhere)
    - `target port` / single or range (target machine which is ec2)
        - classic port: 21,22,80,443, 3389
        - ICMP (Ping)  doesn't use ports
    - outbound RULES:
        - Protocol
        - destination  : IP range/CIDR + `another SG`
        - source port
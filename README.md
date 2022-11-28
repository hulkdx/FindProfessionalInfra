# FindProfessional Infrastructure
FindProfessional services currently using EKS with single node

## Deploy
Currently ci is disabled to apply terraform, enable it by uncomment [this line](.github/workflows/push.yml#L33)

## TODO
- kubernetes version
- latest ami node group
- eks_oidc 
- use private subnets for nodes
- more nodes
- loadbalancer
- autoscaller
- tls

## Infracost
[infracost](https://www.infracost.io/) can be used to see the cost of terraform resources:
```sh
infracost breakdown --path .
```

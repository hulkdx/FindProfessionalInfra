![Build]([https://img.shields.io/github/workflow/status/hulkdx/findprofessional-infra/Deploy%20to%20AWS?style=for-the-badge](https://img.shields.io/github/actions/workflow/status/hulkdx/findprofessional-infra/push.yml?style=for-the-badge))

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

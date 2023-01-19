![Build](https://img.shields.io/github/actions/workflow/status/hulkdx/findprofessional-infra/push.yml?style=for-the-badge&branch=main)

# FindProfessional Infrastructure
FindProfessional services currently using EKS with single node

## Deploy
Currently ci is disabled to apply terraform, enable it by uncomment [this line](.github/workflows/push.yml#L33)

## aws_launch_template
Used for:
- Setting security_group for nodes
- Increasing max pods for each nodes

## TODO
- kubernetes version
- latest ami node group
- eks_oidc 
- use private subnets for nodes
- more nodes
- loadbalancer
- autoscaller
- tls

# Useful tools
## Terraform cloud
[Terraform cloud](app.terraform.io) is used as the backend of this project

## Infracost
[infracost](https://www.infracost.io/) can be used to see the cost of terraform resources:
```sh
infracost breakdown --path .
```

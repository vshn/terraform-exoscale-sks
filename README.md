# VSHN Terraform Module Exoscale SKS

This module does the following:

- Create security group and rules for an SKS cluster
- Create an SKS cluster
- Create nodepools for an SKS cluster

Docs for the SKS provider: https://registry.terraform.io/providers/exoscale/exoscale/latest/docs

## Example usage

```hcl
module "cluster" {
  source = "git::ssh://git@git.vshn.net/vshn-terraform/module-exoscale-sks.git?ref=v1.0.0"

  # fill out the variables
  # ...
}
```

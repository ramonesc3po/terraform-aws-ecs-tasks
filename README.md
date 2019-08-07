Terraform AWS Elastic Load Balancer
===

Developing

Variables
---
```hcl
name = ""
tier = ""
organization = ""
subnets = ""
security_groups = []
```

Example
---
```hcl
module "simple-elb" {
  source = "../../"

  name            = "simple-load-balancer"
  tier            = "production"
  organization    = "example"
  subnets         = aws_subnet.this_public.*.id
  security_groups = [aws_security_group.this.id]
}
```

Author
---
Ramones C3po
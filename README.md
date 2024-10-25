# weighted-target-traffic

Send weighted (percentage of) traffic to different aws resources. 

In this use case we can incrementally move endpoints to ECS from Lambda.

![Infrastructure](docs/infra.drawio.png)

`Deploy` workflow - push on `main` trigger

1. **validate** Check terraform code for any errors.
2. **repo** Setup ECR and S£ repositories.
3. **network** Apply vpc link and api gateway ingress along with load balancer and rules.
4. **image** Build image if changes to `src/*` detected
5. **code** Build Lambda code as zip if changes to `src/*` detected
6. **ecs** Apply ECS cluster, service and task. Rolling deployment only.
7. **lambda** Apply Lambda.


`Destroy` workflow - manual trigger

1. **ecs** Destroy ecs service and task.
2. **lambda** Destroy lambda.
3. **network** Destroy vpc link and api gateway ingress resources.
4. **repo** Destroy ecr, images and lambda s3 zips.

## path weighting

- Define what percentage of traffic is to go to ecs/lambda. In this example 90% will go to Lambda.

```tf
variable "esc_percentage_traffic" {
  type    = number
  default = 10
}

variable "lambda_percentage_traffic" {
  type    = number
  default = 90
}
```

## path rules

- Define which paths are to be weighted. `*` in this example will be a default.

```tf
variable "weighted_paths" {
  type    = list(string)
  default = ["*"]
}
```

- Define which paths are to only got to ecs/lambda. Weighting will subsequently be ignored.

```tf
variable "ecs_only_paths" {
  type    = list(string)
  default = ["small-woodland-creature"]
}

variable "lambda_only_paths" {
  type    = list(string)
  default = ["ice-cream-flavor"]
}
```

## terraform

Required deployment iam privileges.

```json
[
    "dynamodb:*", 
    "s3:*", 
    "ecr:*", 
    "iam:*", 
    "ecs:*", 
    "ec2:*", 
    "elasticloadbalancing:*", 
    "logs:*", 
    "cloudwatch:*", 
    "apigateway:*", 
    "lambda:*"
]
```

## ci config

Required github action variables.
- `AWS_ACCOUNT_ID`
- `AWS_REGION`
- `AWS_ROLE` role with above deployment privileges


## additional spice

Unable to destroy lambda security group (sg). Terraform attempts to delete the sg and is blocked which causes a timeout failure.

**Cause**: lambda is deployed within a VPC by specifying `vpc_config` in the `aws_lambda_function` terraform block.

**Reason**: elastic network interfaces (enis) associated with the sg are still in use on the lambda. This blocks a deletion.

**Solution**: remove the `vpc_config` from the lambda via cli prior to a destroy. This is done via `just detach-function`.
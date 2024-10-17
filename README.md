# weighted-target-traffic

We will look at the below options for weighted traffic.

1. API Gateway with VPC Link: Use API Gateway with a VPC link to direct traffic to your ECS service or Lambda function within the VPC. You can set up Route Request Matching with weighted traffic routing using different routes or stages in API Gateway.

2. Application Load Balancer (ALB): Attach an ALB in front of your ECS service and Lambda. Use weighted target groups to distribute traffic between the ECS service and Lambda. ALB handles traffic routing directly.

3. CloudFront with Weighted Origins: Use CloudFront with weighted origin groups, forwarding requests to your ECS service or Lambda behind the VPC link.
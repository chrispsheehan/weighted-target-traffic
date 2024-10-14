# weighted-target-traffic

1. Load Balancer with Multiple Target Groups (Custom Weighted Approach):
Although AWS Application Load Balancer (ALB) and Network Load Balancer (NLB) don’t natively support weighted routing, you can manually configure weights using multiple instances within target groups.

How it Works: You register different numbers of instances (or tasks) in a single target group to simulate weights. The more instances you register for a particular resource, the more traffic it will receive.

Example:

If you want to split traffic 70/30 between two services, you can register 7 instances of the first service and 3 instances of the second service in a single target group. This will result in 70% of the traffic going to the first service and 30% to the second.
Drawbacks: This method is manual and lacks the fine-grained control of true weighted routing. It also does not scale easily as you need to manage the number of instances registered.

2. Traffic Splitting via ALB Listener Rules:
Using ALB listener rules, you can define conditions to send traffic to different target groups. This method allows traffic routing based on specific HTTP request properties (e.g., path-based or host-based routing).

How it Works:
Define different rules to split traffic to target groups based on factors like URL path, host headers, or query strings.
Example:
Rule 1: Routes /app1/* to Target Group 1.
Rule 2: Routes /app2/* to Target Group 2.
Limitation: This isn’t weighted traffic, but it allows controlled routing based on URL patterns or request attributes.
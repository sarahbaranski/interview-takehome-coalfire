# Coalfire Takehome


## Solution Overview
![Diagram](arch_diagram.png)

## Deployment Instructions
* TBD

## Design decisions and assumptions
* I referenced three-tier web architecture to get an idea of how the infrastructure looks and began to map out a similiar diagram (see top of readme).

* I started with the AWS VPC terraform module because that was something I had already been looking at the other day for a different project and had some familiarity with it. I was able to successfully deploy the VPC with 4 private subnets, and 2 public subnets with a NAT gateway and an Internet gateway and routes configured to both.

* I was torn between using the EC2 module Coalfire has, and the one I ended up going with. It still needs some work to spin up instances in the correct subnets, and key pairs. I grabbed the [apache_install script](https://medium.com/@aaloktrivedi/automating-an-apache-web-server-with-an-amazon-ec2-instance-a-step-by-step-guide-5bad757d0a0e) from this source, and was attempting to spin up on instances in one of the application subnets.

* Things that need to be finished:

  * Finish up the EC2 module, make sure key pair is created for security purposes
  * Add Security groups with the correct rules to allow SSH from that Management tier to the Application tier
  * Finish up the ASG and make sure the instances in the application tier are in that group
  * Add the ALB and security group rules for traffic to the ALB from the instances in the Application tier and from the ALB to the Internet Gateway
  * Add two implemented improvements in code

## References to resources used
* [Three-tier web app](https://medium.com/@aaloktrivedi/building-a-3-tier-web-application-architecture-with-aws-eb5981613e30)

* Various AWS docs based on resources used and module source code

## Analysis
* Instead of using a bastion host, using AWS Systems Manger in order to avoid opening ports and reduce potential attack surfaces and therefore enhancing security.

* A WAF of in front of the ALB could protect the service from potential vulnerabilities.

* I would want to deploy two NAT gateways. One in each public subnet in each AZ. This would maintain high availability but at a cost since Nat Gateways can be expensive. As of right now, if the subnet with the Nat Gateway goes down, then the other Management subnet is dead in the water.

* Having this deployed in more than two AZs, and or across regions, while adding to costs would also make for higher availability (if the database decision was to use Aurora, AWS requires that to be placed in three AZs).

* There isn't any monitoring set up on anything (with the exception of some default monitoring on the ec2 instances). Which is obvious an issue and something that would need to be remedied to make this production ready.

* There need to be health checks in the ASG module, not only to ensure the health of the instances, but also checks to ensure availability of the instances.

* There isn't any sort of Database or S3 bucket set up, but if there was it would probably be beneficial to have backups and/or duplication set up to ensure availability and redundancy.

## Improvement plan with priorities
* Monitoring would be a priority here. Setting up cloudwatch alerts for traffic as well as on the ASG to determine usage. Using CloudTrail to log and monitor actions for auditing and compliance.

* IAM roles. There aren't any in place and in order to ensure that access is done by the appropriate resource or user, those roles and policies would be vital. Enforcing the principle of least privilege on the Application tier would something to add.

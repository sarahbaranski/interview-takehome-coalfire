# Coalfire Takehome


## Solution Overview
![Diagram](arch_diagram.png)

## Deployment Instructions
To SSH into the manangement instance:
Right now this is set up to only run from my ip address. 

```ssh -i "ec2-module-test.pem" ubuntu@PUBLIC_IP_ADDRESS```

PUBLIC_IP_ADDRESS = public ip of the management instance

Should allow you to ssh into the instance.

## Design decisions and assumptions
* I referenced three-tier web architecture to get an idea of how the infrastructure looks and began to map out a similiar diagram (see top of readme).

* I started with the AWS VPC terraform module because that was something I had already been looking at the other day for a different project and had some familiarity with it. I was able to successfully deploy the VPC with 4 private subnets, and 2 public subnets with a NAT gateway and an Internet gateway and routes configured to both. With the local region of us-east-2 and zones 2a and 2b. Initially I didn't have the nat gateway enabled, so that didn't actually work. But I set that var to true and it ended up working.

* Next I decided to impliment the instances. I initially started using `"terraform-aws-modules/ec2-instance/aws"` module, and thought I would have to call it twice. Once for spinning up the application instances in the private subnets and another time for spinning up the management instances in the public subnet. I didn't like that this was repeatable code. I also added the apache script to the application instances that I got from [here](https://medium.com/@aaloktrivedi/automating-an-apache-web-server-with-an-amazon-ec2-instance-a-step-by-step-guide-5bad757d0a0e).

* Before implementing the EC2 module, I went ahead and started to build out the code for the ASG module. I was a bit stuck on the EC2 module. I knew I needed a key pair for the instances, but I wasn't entirely sure how that was going to be generated, so why I was thinking through that I started to set up the ASG code for the application instances. I also chose to hardcode the AMI that I was using just to see if things would work at the time.

* Questioning my apache install script, and doing some googling, I found [this](https://ubuntu.com/tutorials/install-and-configure-apache#2-installing-apache) and realized that script needed to be updated.

* I changed the variable `private_subnet_ids` to `private_subnet` since the value is not actually the id. I did the same for the public one to make sure the naming was clear.

* I decided to use the Coalfire EC2 module, and saw the readme in the samples directory gave instructions on how to create a key pair to pass into the module. This module also required me to change my aws provider version.

* I added the AMI data lookup to the EC2 module, in addition to the ebs_kms_key resources and policy lookup since having the arn for the `ebs_kms_key` is a requirement of the module. Because of the instance type I am using, i set `ebs_optimized` to false as there is no need for it.

* I deployed the instances and got two application instances and two managment instances.

* I began to set up the Auto Scaling Group module and deployed it to find that it deployed the two instances it needed, so I ended up with more instances then I needed. I removed the ec2 module I was using for the application instances, since I realized those would be spun up through the ASG module. I set the `health_check_type` to the ELB based on [this](https://tutorialsdojo.com/ec2-instance-health-check-vs-elb-health-check-vs-auto-scaling-and-custom-health-check/) because I felt like having active/passive health checks could be a benefit.

* I needed to add a security group module to the ASG for the instances it was spinning up since those ingress/egress rules were removed with the ec2 module deletion for the application instances. I also had to pass in the `user_data` with the apache script to the asg module.

* When trying to deploy ALB I learned that it must need two subnets in two different AZs. Which made me think my inital string of 4 private subnets was wrong. I tried filtering through them following the steps I found [here](https://www.acritelli.com/blog/terraform-subnet-per-az/) but wasn't able to get that to work. Partly because none of them were even tagged as Private. So I started looking closer at the VPC module inputs and noticed that I could use [this](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest#input_private_subnet_tags:~:text=no-,intra_subnets,-A%20list%20of).

* I then split my private subnets in half, and added two to a new variable called `intra_subnets`. I also added tags on both my private and intra subnets. I chose intra_subnet over the database option but I think if I had done anything with that tier, I would have put RDS it might make sense to use the database_subnets. The ALB worked.

* I began to test things. Could I ssh into the managment instances. I looked at the instances for the management tier and noticed I was missing the ingress rules in order to ssh into the instance. I also knew that I was going to need to use my ip address in order to ssh in, so I added that var as a input so as not to hardcode my ip.

* Still not being successful at ssh'ing into the instance, I realized that the instance itself didn't have a public ip address for me to hit. Looking back at the VPC module I realized I could add `map_public_ip_on_launch` and it should give a public ip to all the public subnets.

* When I still was unsuccesful I looked back at the EC2 module, and noticed there was a bool for a varaible called `associate_public_ip`. When I set this to true, I was then able to ssh into the management instance.

* I left the Backend tier with just the two intra_subnets. I didn't add a database or s3. I mainly focused on making sure I could fulfill the technical requirements.


## References to resources used
* [Three-tier web app](https://medium.com/@aaloktrivedi/building-a-3-tier-web-application-architecture-with-aws-eb5981613e30)

* [VPC module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest?tab=inputs)

* [Initial EC2 module used before using Coalfile EC2 module](https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest)

* [EC2 key pairs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)

* [KMS key resource and policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)

* [ebs-optimized](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-optimized.html#current-general-purpose)

* [ASG module](https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/latest)

* [SG module](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest)

* [base64encode function for user data reference](https://developer.hashicorp.com/terraform/language/functions/base64encode)

* [ALB module](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest)

* [Subnet data source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets)

## Analysis
* Instead of using a bastion host, using AWS Systems Manger in order to avoid opening ports and reduce potential attack surfaces and therefore enhancing security. Or at the very least, have seperate key/pairs per instance.

* A WAF of in front of the ALB could protect the service from potential vulnerabilities.

* In order to secure incoming HTTPS traffic to the application tier, I would probably want to associate a ACM SSL cert with the ALB.

* I would want to deploy two NAT gateways. One in each public subnet in each AZ. This would maintain high availability but at a cost since Nat Gateways can be expensive. As of right now, if the subnet with the Nat Gateway goes down, then the other Management subnet is dead in the water.

* Having this deployed in more than two AZs, and or across regions, while adding to costs would also make for higher availability (if the database decision was to use Aurora, AWS requires that to be placed in three AZs).

* There isn't any monitoring set up on anything (with the exception of some default monitoring on the ec2 instances). Which is obvious an issue and something that would need to be remedied to make this production ready.

* There isn't any sort of Database or S3 bucket set up, but if there was it would probably be beneficial to have backups and/or duplication set up to ensure availability and redundancy.

## Improvement plan with priorities
1. Monitoring would be a priority here. Setting up cloudwatch alerts for traffic as well as on the ASG to determine usage. Using CloudTrail to log and monitor actions for auditing and compliance.

2. Having a database on the backend tier with security group rules allowing the application tier to communicate with the database.

3. IAM roles. There aren't any in place and in order to ensure that access is done by the appropriate resource or user, those roles and policies would be vital. Enforcing the principle of least privilege on the Application tier would be something to add. Maybe adding IAM group roles for who can access the Management instances would be something to consider.

## Final Notes
I have experience working with these components but in my experience a lot of this was always set up already and I would do some tweaking. I really enjoyed being able to make something work from scratch, discovering some things about what makes all these resources work and how those things are defined in Terraform, as well as thinking about the security implications that comes with this. I am sure I haven't thought of everything, and I'd welcome a conversation to hear about anything I didn't consider.
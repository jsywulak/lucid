# Terraform Project #

Do you like auto scaling groups? Do you like RDS instances? Do you like ALBs fronting it all? And maybe you're okay with a couple shortcuts because this isn't production? Well, I got the repo for you!

# Assumptions / Apologies:
* Gonna just use local state 
* "sam" is some relevant acronym I'm just not grokking, and should change it all to "jonny"
* Set up Terraform to prompt for a DB password, but ideally it would be already set by another process outside of Terraform.
* Gave the RDS instance a specific static identifier to make it easy to lookup; if I was ever gonna run this twice, I'd need to do something else.
* Did some Terraform output lookups instead of doing something fancy in Ruby so that the tests were independent of the infrastructure; if this was something where it wasn't being closely monitored, I'd want to factor that away.

# Prereqs
* Have AWS creds set up to a default profile
* Have Terraform installed
* Ruby installed
* jq installed (or be handy with copy / paste )
* Have the attention span to remember to destroy this 

# Instructions

	terraform init
	terraform plan
    terraform apply 
    open $(terraform output -json lb_dns_name |  jq -r .)

Once you're done, you can tear it down with

	terraform destroy -var=db_password=doesntmatter

# Specs

Used [awspec](https://github.com/k1LoW/awspec/) for testing. To install and run you'll need ruby; if you already have ruby installed you can just run the last two commands. 

	brew install asdf
	asdf install ruby
	bundle install
	bundle exec rake spec

*Note*: it assumes your default region from `aws configure` so if you're overriding that for terraform you'll need to do it for awspec, too.

# Thoughts on furthering it

_How would a future application obtain the load balancer’s DNS name if it wanted to use this service?_

Easiest thing would probably be just to add a Route 53 entry that points to the ALB, and then any consuming applications can point at that.

_What aspects need to be considered to make the code work in a CD pipeline (how does it successfully and safely get into production)?_

You'd probably want to separate the concerns a bit here so that resources with different lifetimes are managed by different Terraform applications (eg the lifecycle of the RDS instance is going to be much much different than the Launch Config). For routine app deployments, you'd have three steps in your pipeline: AMI build; Launch Config Update; ASG Refresh. The ALB and RDS instance should be mostly static, but you could have their own pipeline flows for deploying them. (For the RDS instance, you'd probably want to also have pretty robust backup creation and use as part of it, too.)

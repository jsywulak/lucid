# Lucid HQ Infrastructure Terraform Code Test #

Using AWS and the Terraform in this repository to provision the network create a simple web server with associated database.

# Assumptions:
* Gonna just use local state 
* "sam" is some relevant acronym I'm just not grokking, and should change it all to "jonny"
* Set up Terraform to prompt for a DB password, but ideally it would be already set.
* Gave the RDS instance a specific static identifier to make it easy to lookup; if I was ever gonna run this twice, I'd need to do something else.

# Specs

Used [awspec](https://github.com/k1LoW/awspec/) for testing. To install and run you'll need ruby; if you already have ruby installed you can just run the last two commands. 

	brew install asdf
	asdf install ruby
	bundle install
	bundle exec rake spec

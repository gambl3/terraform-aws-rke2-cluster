# Terraform Module for RKE2 on AWS

**Please review the information below and follow the instructions to deploy this module!**

## Prerequisites

- Git Utility, Terminal Utility, and HashiCorp Terraform with Access to the AWS Provider Plugin
- AWS Commercial or AWS GovCloud Account with the appropriate elevated privileges to interact with AWS Services

## Configuration

**Step 1:** Ensure Terraform is installed and create a working directory.

**Step 2:** Copy the code below into a file named `main.tf` and set the required variables or additional optional variables!

```bash
module "rke2-cluster" {
  source  = "zackbradys/rke2-cluster/aws"
  version = "1.2.1"

  region        = "us-east-1"
  key_pair_name = "AWS_KEY_PAIR_NAME"
  domain        = "example.com"
  prefix        = "rke2-cluster"
}
```

**Step 3:** Run the commands below to deploy and provision your infrastructure!

```bash
terraform init

terraform plan

terraform apply --auto-approve
```

**Step 4:** Wait about 10 minutes and access your busted/non-functional RKE2 Cluster! SSM can be used to access the nodes to endlessly troubleshoot.
### Contributing

Please utilize GitHubs features such as Issues, Forks, and Pull Requests to contribute to this code!

### About Me

A little bit about me and my history in the industry. If you have any questions, please reach out to me at zbrady@zackbrady.com!

- Contractor
- Retired Army

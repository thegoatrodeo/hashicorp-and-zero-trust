---
title: Readme.md
tags: readme build script
---

# Hashicorp and Zero Trust 

This codebase is designed to create an Instruqt workshop demonstrating a complete multi-cloud, HashiCorp Zero-Trust platform.  In this workshop, we are creating the following: 

- Two Cloud environments
  - [Azure VNET](https://github.com/thegoatrodeo/azure-vnet)
  - [AWS VPC](https://github.com/thegoatrodeo/aws-vpc)
- VPC Peering between the two cloud environments.
- HashiCorp Consul Service Network connecting the two environments.
- HashiCorp Boundary for entry into the environment.
- HashiCorp Vault for Secrets Management and mTLS auth between applications.
- 2 Applications
- SSO - via Active Directory integrated with Vault.


---
## File: track.yml 

The [Track.yml](https://docs.instruqt.com/tracks/configuration/track) sets up the overall course an each track within the course.  This is where instructions for each step are created.  The first part of the `track.yml` lays out the overall course details, including:  *title, description, teaser, owner* etc..   

```yaml  tangle:./track.yml
type: track
slug: multi-cloud-demo
id: louupoysv1yr
title: Multi-Cloud Demo
teaser: This is a Sandbox for a Multi-Cloud demo.
contents: |
  You are being provisioned on-demand cloud infrastructure. <br>
  Please be patient as this can take up to ~15 minutes.
description: |
  This is a long description of the track -

  You can use any GitHub flavoured markdown.
icon: https://storage.googleapis.com/instruqt-frontend/img/tracks/default.png
tags: []
owner: hashicorp
developers:
- daniel.fedick@hashicorp.com
private: false
published: false
show_timer: true
```

### Track challenges
[Challenges](https://docs.instruqt.com/tracks/configuration/track#challenge) specify the the title, teaser description and any other information about each challenge.  
The `id` is created and spliced into each challenge when the `instruqt track push` command is run to push the latest changes of the course  to the Instruqt platform.

```yaml tangle:./track.yml
challenges:
- slug: 01-multi-cloud-challenge
  id: 3mztnatufhk9
  type: challenge
  title: Create AWS Cloud and GCP
  teaser: Learn how to create a directory
  notes:
  - type: text
    contents: |
      When this course starts, the following will be available: 
      - Terraform Binary 
      - AWS Organization 
        - Github repsitory for creating an AWS VPC 
      - Azure subscription 
        - Github repository for creating an Azure VNET
```

The assignment field is where the instructions in the Instruqt sidebar are created.  
In this Readme case there are nested code blocks so we use the `~~~` characters to pass through the codeblock to the sidebar.

```yaml tangle:./track.yml
  assignment: |-

    Run the following command to create the AWS VPC: 
    ~~~
    terraform init
    terraform apply -var="access_key=${AWS_ACCESS_KEY_ID}" -var="secret_key=${AWS_SECRET_ACCESS_KEY}" -auto-approve
    ~~~

    Run the following command to create the Azure VNET: 
    
    ~~~
    terraform init
    terraform apply -var="subscription_id=${ARM_SUBSCRIPTION_ID}" -var="client_id=${ARM_CLIENT_ID}" -var="client_secret=${ARM_CLIENT_SECRET}" -var="tenant_id=${ARM_TENANT_ID}" -auto-approve
    ~~~

```

The Tabs are available at the top of the web browser while going through each challenge.  Below, we've setup a tab to access a shell terminal in the first assignment.  Also we've setup access to the AWS Console and Azure Portal. 
```yaml tangle:./track.yml
  tabs:
  - title: Cloud Console/Portals
    type: service
    hostname: cloud-client
    path: /
    port: 80
  - title: Cloud CLI
    type: terminal
    hostname: cloud-client
```

The Timelimit is an integer in seconds.   This is the [challenge](https://docs.instruqt.com/tracks/configuration/track#challenge) time limit.  It is not enforced.  The Track Timelimit is.  The Track timelimit is the sum of all challenge time limits. 

The difficulty can be expressed as `basic`,   `intermediate`, `advanced` or `expert`.

```yaml tangle:./track.yml
  timelimit: 6000
  difficulty: basic
```

The following checksum is created and spliced into the file after the `instruqt track push` command is run to push the course up to the Instruqt platform.

```yaml tangle:./track.yml
checksum: "13644327770291811785"
```

---
## File: config.yml

Setup the [Instruqt cloud-client](https://docs.instruqt.com/sandbox-environment/cloud-accounts#accessing-google-cloud-projects) (Hosted by GCR) that has the Azure/AWS/GCP cli access tools.  This client will be used as the interface for the learner to access the CSP's (Cloud Service Providers) and run shell commands within the tracks.

```yaml  tangle:./config.yml
version: "2"
containers:
- name: cloud-client
  image: gcr.io/instruqt/cloud-client
  ports: [80]
  shell: /bin/bash
```

Configure the Azure subscription provisioned by Instruqt. 
Once the subscription is created, the information about the subscription can be accessed by [special variables:](https://docs.instruqt.com/sandbox-environment/cloud-accounts#environment-variables)  

```yaml tangle:./config.yml
azure_subscriptions:
- name: ZT_AZ
  roles:
  - Contributor
``` 

Setup the [Instruqt AWS Subscription](https://docs.instruqt.com/sandbox-environment/cloud-accounts#environment-variables).  By specifying this block an AWS account is created by Instruqt. Configuration information regarding this account is available via [special variables](https://docs.instruqt.com/sandbox-environment/cloud-accounts#environment-variables-1)  provided after the account is created. 

```yaml tangle:./config.yml
aws_accounts:
- name: ZT_AWS
  managed_policies:
  - arn:aws:iam::aws:policy/AdministratorAccess
```

---
## File: setup-cloud-client 
The setup-cloud-client script is the script that is run when Instruqt initially loads.  To successfully start the Instruqt lab, all instructions in setup script need to be run with an `exit 0`.


Set the variables for Terraform version and download link.
The [Terraform Download Page](https://www.terraform.io/downloads.html) can be used to get and change the latest version or platform for the Terraform binary.

```bash tangle:./track_scripts/setup-cloud-client
#!/bin/bash

TF_VERSION=1.0.11
TF_PLATFORM=linux_amd64
TF_URL=https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_${TF_PLATFORM}.zip
TF_DOWNLOAD=terraform_${TF_VERSION}_${TF_PLATFORM}.zip

echo "source /etc/profile.d/instruqt-env.sh" >> /root/.bashrc
source /root/.bashrc

```


## Setup The Install Terraform Function: 
The following bash function is used to get the requested version and platform and install into `/usr/local/bin/`
Terraform should be available in `/usr/local/bin/terraform`  and in the execute `$PATH`.  

```bash tangle:./track_scripts/setup-cloud-client

install_tf() {
  set-workdir /tmp
  wget ${TF_URL}
  unzip ${TF_DOWNLOAD}
  mv terraform /usr/local/bin/
}
install_tf

```

## Get the repository that creates the AWS VPC
Get the aws-vpc repository from Github. This is a public repository, so no git credentials necessary.

```bash tangle:./track_scripts/setup-cloud-client

install_aws_vpc() {
  set-workdir ~/
  git clone https://github.com/thegoatrodeo/aws-vpc.git && set-workdir ~/aws-vpc
  cd ~/aws-vpc
  echo "git status"
  git status
  git pull && /usr/local/bin/terraform init
  /usr/local/bin/terraform apply -var="access_key=${AWS_ACCESS_KEY_ID}" -var="secret_key=${AWS_SECRET_ACCESS_KEY}" -auto-approve
}
install_aws_vpc

```


## Get the repository that creates the Azure VNET
Get the azure-vnet repository from Github. This is a public repository, so no git credentials necessary.

```bash tangle:./track_scripts/setup-cloud-client


install_azure_vnet() {
  cd /root
  echo "PWD:: ${pwd}"
  echo "############################"
  echo "ARM_SUBSCRIPTION_ID: ${ARM_SUBSCRIPTION_ID}"
  echo "############################"
  git clone https://github.com/thegoatrodeo/azure-vnet.git 
  cd ~/azure-vnet
  echo "git status"
  git status
  git pull && /usr/local/bin/terraform init
  /usr/local/bin/terraform apply -var="subscription_id=${ARM_SUBSCRIPTION_ID}" -var="client_id=${ARM_CLIENT_ID}" -var="client_secret=${ARM_CLIENT_SECRET}" -var="tenant_id=${ARM_TENANT_ID}" -auto-approve
}
install_azure_vnet

```


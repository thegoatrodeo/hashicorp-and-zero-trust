---
title: Readme.md
tags: readme build script
---

# Track.yml 

The [Track.yml](https://docs.instruqt.com/tracks/configuration/track) sets up the guide that walks you through the instruction.  This is where the instructions for each step are created.  The first part of the `track.yml` sets up the overall course description.  (Title, description, teaser, owner etc..). 

```yaml  tangle:./track.yml
type: track
slug: multi-cloud-demo
id: louupoysv1yr
title: Multi-Cloud Demo
teaser: This is a Sandbox for a Multi-Cloud demo.
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

### Challenges
[Challenges](https://docs.instruqt.com/tracks/configuration/track#challenge) specify the the title, teaser description and any other information about each challenge.  
The `id` is created and spliced into each challenge when the `instruqt track push` command to push the latest changes of the course  to the Instruqt platform.

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
        - AWS VPC 
      - Azure subscription 
```

The assignment field is the title of the challenge.  
```yaml tangle:./track.yml
  assignment: |
    Run the following command to create the VPC: 
    ```
    terraform apply -var="access_key=${AWS_ACCESS_KEY_ID}" -var="secret_key=${AWS_SECRET_ACCESS_KEY}"
    ```
```

The Tabs are available at the top of the web browser while going through each challenge.  Below, we've setup a tab to access a shell terminal.  Also we've setup access to the AWS Console and Azure Portal. 
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
checksum: "12924893148077563444"
```

# Config.yml

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
- name: azuresubscription
  roles:
  - Contributor
``` 

Setup the [Instruqt AWS Subscription](https://docs.instruqt.com/sandbox-environment/cloud-accounts#environment-variables).  By specifying this block an AWS account is created by Instruqt. Configuration information regarding this account is available via [special variables](https://docs.instruqt.com/sandbox-environment/cloud-accounts#environment-variables-1)  provided after the account is created. 

```yaml tangle:./config.yml
aws_accounts:
- name: awsaccount
```


# setup-cloud-client shell script

Set the Variables for Terraform Version and Download link.
The [Terraform Download Page](https://www.terraform.io/downloads.html) can be used to get and change the latest version or platform for the Terraform binary.

```bash tangle:./track_scripts/setup-cloud-client
#!/bin/bash

TF_VERSION=1.0.11
TF_PLATFORM=linux_amd64
TF_URL=https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_${TF_PLATFORM}.zip
TF_DOWNLOAD=terraform_${TF_VERSION}_${TF_PLATFORM}.zip

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
get_aws_vpc_repo() {
  set-workdir ~/
  git clone https://github.com/thegoatrodeo/aws-vpc
  set-workdir ~/aws-vpc
}
get_aws_vpc_repo
```
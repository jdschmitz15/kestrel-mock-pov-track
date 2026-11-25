---
slug: onboard-aws-cloudsecure
id: npsk6xsbfymv
type: challenge
title: Onboard AWS to CloudSecure
teaser: Connect the customer's AWS account so the PCE can see RDS and VPC flow logs.
tabs:
- id: 6h0g9479thrb
  title: AWS Console
  type: service
  hostname: cloud-client
  path: /
  port: 80
- id: se9569466hz3
  title: Client
  type: terminal
  hostname: kp-client01
- id: 3lykogeeby3y
  title: PCE
  type: website
  url: https://console.illum.io/
  new_window: true
difficulty: basic
timelimit: 1200
enhanced_loading: null
---
RDS can't run a VEN, but the security team wants to see what talks to it (ask 2). CloudSecure reads
the AWS account's inventory and VPC flow logs, so RDS shows up on the map without an agent.

The Portal app is already running in your AWS account:

```bash
cat ~/kestrel/aws-details.txt
```

Flow logs for the Portal VPC go to this bucket: `[[ Instruqt-Var key="FLOWLOG_BUCKET" hostname="kp-client01" ]]`

## 1. Start onboarding in the PCE

In the **PCE** tab, go to **CloudSecure > Onboarding** (in some menus it is **Cloud > Accounts**) and
add an **AWS** account. Use the account ID from `aws-details.txt`. Choose to onboard with
**CloudFormation**.

## 2. Run the CloudFormation stack in AWS

Open the **AWS Console** tab and log in with the credentials shown there. The PCE gives you a link to
launch the stack. Open it in the console, accept the IAM acknowledgement, and create the stack. It
creates a read-only role that Illumio uses.

## 3. Add the flow log bucket

Back in the PCE, finish onboarding and add the flow log bucket above as a flow log source for the
account (make sure the region matches the one in `aws-details.txt`).

> [!NOTE]
> Inventory appears in a few minutes. Flow data takes longer, usually 10 to 20 minutes. Move on and
> come back to the map in challenge 6.

Click **Check** when the CloudFormation stack is complete.

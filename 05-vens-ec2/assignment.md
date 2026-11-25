---
slug: vens-ec2
id: 7sacqdeuqes6
type: challenge
title: Install VENs on the AWS Portal servers
teaser: Pair VENs on the four EC2 instances through Systems Manager.
tabs:
- id: vfdoztnodhuj
  title: Client
  type: terminal
  hostname: kp-client01
- id: cwrnwu41vnxf
  title: AWS Console
  type: service
  hostname: cloud-client
  path: /
  port: 80
- id: 0hgevdagkorz
  title: PCE
  type: website
  url: https://console.illum.io/
  new_window: true
difficulty: basic
timelimit: 1200
---
The Portal app runs on four EC2 instances with no public IP and no SSH keys. That is normal at
customers: you use the tools they already have. Here that is AWS Systems Manager.

## 1. Look at the instances

```bash
kp list
```

## 2. Pair all four in one go

Generate a key on **Kestrel-POV** in the **PCE** tab and copy the **Linux** command. Then run it on all
four instances through SSM (keep the single quotes):

```bash
kp run aws '<paste the Linux pairing command here>'
```

If one fails, you can open a shell on it with `kp ssh kp-papp01` and look at
`/opt/illumio_ven/illumio-ven-ctl status`.

## 3. Check the PCE

**Workloads** now shows ten VEN workloads, all online and in **Visibility Only**.

Click **Check** when all four EC2 instances are paired.

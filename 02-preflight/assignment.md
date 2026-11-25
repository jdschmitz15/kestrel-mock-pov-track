---
slug: preflight
id: ekp1bgkdryyq
type: challenge
title: Run pre-flight checks
teaser: Confirm every in-scope server runs a supported OS and can reach the PCE on 443.
tabs:
- id: lvs0wjebkt5m
  title: Client
  type: terminal
  hostname: kp-client01
- id: cwttv0xoe5uy
  title: Web
  type: terminal
  hostname: kp-web01
- id: p960adqlt8np
  title: Reporting
  type: terminal
  hostname: kp-rpt01
- id: 1qjfrye8u9wu
  title: Ubuntu
  type: terminal
  hostname: kp-ubu01
- id: dvt87b6sf45z
  title: SQL (RDP)
  type: service
  hostname: guac
  path: /#/client/c/kp-sql01?username=guac_user&password=guac_password
  port: 8080
- id: bjnxhs3dk6jh
  title: Windows (RDP)
  type: service
  hostname: guac
  path: /#/client/c/kp-win01?username=guac_user&password=guac_password
  port: 8080
difficulty: basic
timelimit: 900
---
Before you install anything, prove that each server can take a VEN. On a real POV this is the check that
saves you a wasted morning: an unsupported OS or a blocked firewall rule is found now, not during install.

Each server has a `preflight` command. It checks the OS and that HTTPS to the PCE works, then saves the
result. Your PCE hostname is in `/root/.pce/env` on the **Client** tab:

```bash
grep PCE_FQDN /root/.pce/env
```

## 1. Linux servers

In each of the **Client**, **Web**, **Reporting** and **Ubuntu** tabs run (use your own hostname):

```bash
preflight <your-pce-hostname>
```

## 2. Windows servers

Open the **SQL (RDP)** and **Windows (RDP)** tabs. In each, open a command prompt and run:

```
preflight <your-pce-hostname>
```

## 3. AWS servers

The four Portal EC2 instances have no public IP. You reach them through AWS Systems Manager. In the
**Client** tab run:

```bash
kp list
kp preflight
```

`kp preflight` runs the check on all four and saves the results to `~/kestrel/preflight-aws.txt`.

Every line should end in **PASS**. Click **Check** when they do.

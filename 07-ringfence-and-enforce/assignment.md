---
slug: ringfence-and-enforce
id: cb8dg53kstzr
type: challenge
title: Ringfence the Claims app and enforce
teaser: Write the Claims policy, move it to full enforcement, and prove the reporting
  server is blocked.
tabs:
- id: jiei1wfy1amp
  title: Client
  type: terminal
  hostname: kp-client01
- id: 2hmyv9izjguk
  title: Reporting
  type: terminal
  hostname: kp-rpt01
- id: fpdnbvd84cmh
  title: Web
  type: terminal
  hostname: kp-web01
- id: vjf0lehsngra
  title: SQL (RDP)
  type: service
  hostname: guac
  path: /#/client/c/kp-sql01?username=guac_user&password=guac_password
  port: 8080
- id: vhuvscfdjo85
  title: PCE
  type: website
  url: https://console.illum.io/
  new_window: true
difficulty: basic
timelimit: 1800
enhanced_loading: null
---
Ask 1: reporting must go through the Claims app, never straight to the database. You found that
`kp-rpt01` talks to SQL on 1433. Now you write the policy that stops it, without breaking the app.

## 1. Create the ruleset

In **Policy > Rulesets** add a ruleset named exactly **Claims | POV**, scoped to **App: Claims**,
**Env: POV**. Add these rules:

| # | Source | Destination | Service | Notes |
| --- | --- | --- | --- | --- |
| 1 | Role Client, App Users (extra-scope) | Role Web | TCP 80 | Users reach the app |
| 2 | Role Web | Role DB | TCP 1433 | App reaches its database |
| 3 | IP list **Any (0.0.0.0/0 and ::/0)** (extra-scope) | All workloads | TCP 22, 3389, 5985 | Keeps the lab terminals and RDP working |
| 4 | All workloads | IP list **Any (0.0.0.0/0 and ::/0)** | UDP 53, TCP 53 | DNS out |

**Provision** the ruleset.

> [!WARNING]
> Rules 3 and 4 are lab plumbing. On a real POV you would scope admin access to jump hosts. If you
> skip them, full enforcement cuts off this lab's terminals and name resolution.

## 2. Check before you enforce

Open the map for the Claims app with **policy decision** colouring. Flows from Users to Web and from
Web to DB show as **allowed**. The flow from `kp-rpt01` to `kp-sql01:1433` shows as **blocked** (it
would be blocked if enforced). This is the screenshot customers remember.

## 3. Enforce

Set **kp-web01** and **kp-sql01** to **Full** enforcement (**Workloads**, select both, **Edit
Enforcement**).

## 4. Prove it

In the **Reporting** tab:

```bash
ncat -zv -w 3 kp-sql01 1433
```

It should time out. In the **Client** tab the app still works:

```bash
curl -s -o /dev/null -w '%{http_code}\n' http://kp-web01/
```

You should see `200`.

Click **Check** when the reporting server is blocked and the app still answers.

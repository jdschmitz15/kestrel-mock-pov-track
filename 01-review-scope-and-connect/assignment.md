---
slug: review-scope-and-connect
id: hkvqu60txob9
type: challenge
title: Review the scope and connect to your PCE
teaser: Read the signed-off scoping sheet, then connect the lab to your own SaaS PCE org.
tabs:
- id: cpikc6exxpjh
  title: Scoping sheet
  type: code
  hostname: kp-client01
  path: /root/kestrel
- id: ynqx7btcppjo
  title: Client
  type: terminal
  hostname: kp-client01
- id: 34txgyjjn2dg
  title: PCE
  type: website
  url: https://console.illum.io/
  new_window: true
difficulty: basic
timelimit: 900
---
Kestrel Point Insurance has signed off the POV scope. Discovery is done, so your job today is to
deliver what the scoping sheet promises.

## 1. Read the scoping sheet

Open the **Scoping sheet** tab and read `scoping-sheet.md`. Note three things:

- The **in scope** servers: 6 VMs get a VEN, 4 EC2 instances in AWS get a VEN, and RDS is covered by CloudSecure.
- The three **security team asks**. Every later challenge maps to one of them.
- The four **success criteria**. You fill these in at the end.

## 2. Connect the lab to your PCE

Your welcome email has your PCE hostname, org ID, and an API key and secret. In the **Client** tab run:

```bash
pov-connect
```

It saves your details to `/root/.pce/env`, tests the API key, and creates a pairing profile called
**Kestrel-POV** in visibility-only mode. Every VEN in this POV pairs with that profile.

## 3. Log in to the PCE

Open the **PCE** tab (it opens in a new window) and log in. Go to **Workloads and VENs > Pairing Profiles**
and confirm that **Kestrel-POV** is there with enforcement set to **Visibility Only**.

> [!NOTE]
> Starting every workload in visibility only is the POV habit to build. Nothing is blocked until you
> decide it should be, and the customer sees value on day one.

Click **Check** when the profile exists.

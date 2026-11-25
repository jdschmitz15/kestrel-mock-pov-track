---
slug: label-and-find
type: challenge
title: Label the apps and find the findings
teaser: Apply the four-dimension labels, then use the map to answer the security team's questions.
tabs:
- title: Client
  type: terminal
  hostname: kp-client01
- title: Scoping sheet
  type: code
  hostname: kp-client01
  path: /root/kestrel
- title: PCE
  type: website
  url: https://console.illum.io/
  new_window: true
difficulty: basic
timelimit: 1500
---
A map of IP addresses means nothing to a customer. Labels turn it into their apps. The label plan was
agreed during scoping and is in `labels.csv` (open it in the **Scoping sheet** tab).

## 1. Apply the labels

Label every workload with **Role**, **App**, **Env** and **Location** from `labels.csv`.

Two ways to do it, pick one:

- **PCE UI:** **Workloads**, select workloads, **Edit Labels**. Create a label when the PCE asks.
- **API:** `pce label-href app Claims --create` prints a label href, and
  `pce raw PUT <workload-href> '{"labels":[{"href":"..."}, ...]}'` sets labels. This is the faster way
  on a real POV with hundreds of servers.

## 2. Read the map

Open **Explore > Map** (or **Illumination**). Give it a few minutes if flows are still arriving.
Then answer the three questions in `~/kestrel/answers.txt`. Put your answer after the colon:

1. **reaches-claims-db-from-outside**: which workload, other than the Claims web tier, talks to the
   Claims database on 1433? Give its hostname.
2. **portal-app-talks-to-without-a-ven**: the Portal app tier talks to something that has no VEN.
   What kind of AWS resource is it? (CloudSecure shows it.)
3. **seen-only-through-ipfix**: one IP address talks to the Claims database but appears only through
   the NEN's IPFIX data. What is it?

```bash
nano ~/kestrel/answers.txt
```

> [!NOTE]
> Hint for 3: use **Explore > Traffic** and filter on the destination `kp-sql01`, port 1433.

Click **Check** when the labels are on and the answers are in.

---
slug: vens-instruqt
id: 2taqkmhzt9vn
type: challenge
title: Install VENs and pair the NEN
teaser: Pair VENs on six data center servers in visibility only, and pair the NEN
  that collects IPFIX.
tabs:
- id: g5krmje8etxl
  title: Client
  type: terminal
  hostname: kp-client01
- id: baisjqsxvy91
  title: Web
  type: terminal
  hostname: kp-web01
- id: oa2zybo2tgyv
  title: Reporting
  type: terminal
  hostname: kp-rpt01
- id: f161cn6byjvy
  title: Ubuntu
  type: terminal
  hostname: kp-ubu01
- id: y1nojvzmgkdx
  title: SQL (RDP)
  type: service
  hostname: guac
  path: /#/client/c/kp-sql01?username=guac_user&password=guac_password
  port: 8080
- id: dsbtikraa10c
  title: Windows (RDP)
  type: service
  hostname: guac
  path: /#/client/c/kp-win01?username=guac_user&password=guac_password
  port: 8080
- id: eesxgy1cmy2h
  title: NEN
  type: terminal
  hostname: kp-nen01
- id: elqyfo5jfckv
  title: Flow
  type: terminal
  hostname: kp-flow01
- id: rx9yhsdk5lxt
  title: PCE
  type: website
  url: https://console.illum.io/
  new_window: true
difficulty: basic
timelimit: 1800
enhanced_loading: null
---
Now install VENs on the six data center servers, and pair the NEN that will receive IPFIX from the
"core switch" (ask 3: a scanner with no agent).

## 1. Get a pairing command

In the **PCE** tab open **Workloads and VENs > Pairing Profiles > Kestrel-POV** and click
**Generate Key**. The PCE shows a Linux command and a Windows command. Each key can be used many times
until it expires.

> [!NOTE]
> Want the activation code alone? Run `pce pairing-key` in the **Client** tab.

## 2. Linux VENs (4 servers)

Paste the Linux command as root in each of these tabs: **Client**, **Web**, **Reporting**, **Ubuntu**.

Check each with:

```bash
/opt/illumio_ven/illumio-ven-ctl status
```

## 3. Windows VENs (2 servers)

In the **SQL (RDP)** and **Windows (RDP)** tabs, open **PowerShell as Administrator** and paste the
Windows command.

## 4. Pair the NEN

`kp-nen01` has the NEN software installed and no VEN. Get an activation code in the **Client** tab:

```bash
pce pairing-key
```

Then pair the NEN in the **NEN** tab:

```bash
illumio-nen-ctl activate --management-server <your-pce-hostname>:443 --activation-code <code>
```

Then enable IPFIX collection on UDP **4739** following the NEN guide section on flow collectors.
The **Flow** tab runs the exporter, which sends IPFIX to `kp-nen01:4739` every few seconds:

```bash
docker logs --tail 5 ipfix-gen
```

## 5. Check the PCE

Under **Workloads and VENs > Workloads** you should see six workloads, all online, all in
**Visibility Only**. The NEN appears under **Network Enforcement Nodes**.

Click **Check** when all six VENs and the NEN are paired.

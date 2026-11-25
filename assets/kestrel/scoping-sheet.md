# Kestrel Point Insurance: POV scoping sheet

Signed off after the discovery call. You don't need to change anything above
"Success criteria" until challenge 8.

## Customer

| Item | Answer |
| --- | --- |
| Company | Kestrel Point Insurance (fictional) |
| Champion | Head of Infrastructure Security |
| Why now | Auditors flagged flat networks around the claims database |
| PCE | Illumio SaaS, one org for the POV |
| Proxy | None. Servers have direct outbound 443 |
| Agent budget | 25 VENs for the POV. RDS and other PaaS are covered by CloudSecure, not VENs |

## In scope

| Site | Servers | Notes |
| --- | --- | --- |
| Data center (Instruqt) | kp-web01, kp-sql01, kp-rpt01, kp-client01 | Claims app: web on Ubuntu, SQL Server on Windows. Reporting server and a user test client next to it |
| Data center (Instruqt) | kp-ubu01, kp-win01 | Standalone servers for the platform team to watch a VEN install |
| Data center (Instruqt) | kp-nen01 | NEN to collect IPFIX from the core switch (no VEN) |
| Data center (Instruqt) | kp-flow01 | Stands in for the core switch: exports IPFIX (no VEN) |
| AWS | kp-pweb01/02, kp-papp01/02, RDS | Customer Portal: ALB, web, app, Postgres RDS with a read replica. VPC flow logs go to S3 |

## Security team asks

1. Reporting must go through the Claims app, never straight to the database.
2. They want to see what talks to RDS, even though RDS can't run an agent.
3. They suspect an old network scanner still touches the database. It has no agent.

## Success criteria

Fill in **Status** (Met / Not met) and one line of **Evidence** for each row in challenge 8.

| # | Criterion | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Both apps (Claims and Portal) visible on the map with labels |  |  |
| 2 | RDS traffic visible through CloudSecure and VPC flow logs |  |  |
| 3 | Reporting server blocked from the Claims database, app still works |  |  |
| 4 | Traffic from hosts without a VEN visible through the NEN (IPFIX) |  |  |

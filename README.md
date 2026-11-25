# Kestrel Point Mock POV (Instruqt classic track)

A two-hour practice POV for new Illumio SEs. Each student gets 8 Instruqt VMs, one AWS account
with a three-tier Portal app (RDS and VPC flow logs), and their own SaaS PCE org. Discovery and
scoping are done before the track starts. Discovery is practised in a separate track.

Classic track format (not Labs 2.0), because the lab uses Windows VMs.

## Build and push

Instruqt lifecycle scripts can't read files from this repo, so the build step inlines what they need.

```bash
python3 tools/build.py      # writes track_scripts/ and the challenge folders from src/
instruqt track validate
instruqt track push
```

Edit files under `src/` and `assets/`, never the generated `track_scripts/` or challenge scripts.
`assignment.md` files are copied from `src/challenges/` too.

## Secrets (set in the Instruqt team settings)

| Secret | Used by | What it is |
| --- | --- | --- |
| `NEN_RPM_URL` | setup-kp-nen01 | Download URL for the NEN 2.7.10+ RPM. For a release asset in a private GitHub repo: `https://api.github.com/repos/<owner>/<repo>/releases/assets/<asset-id>` |
| `NEN_GITHUB_TOKEN` | setup-kp-nen01 | Fine-grained, read-only (Contents: read) token for that private repo. Set to `none` for a public URL |
| `PCE_TEST_FQDN`, `PCE_TEST_PORT`, `PCE_TEST_ORG`, `PCE_TEST_KEY`, `PCE_TEST_SECRET` | solve scripts only (optional) | A throwaway PCE org for `instruqt track test`. Commented out in config.yml; create them in team settings, then uncomment. Students enter their own org with `pov-connect` |

## Region

The Portal app's region is `AWS_REGION` at the top of `src/track_scripts/setup-kp-client01.tpl`
(default `us-east-1`). It must be one of the regions under `aws_accounts` in `config.yml`.

## Layout

| Path | What |
| --- | --- |
| `track.yml`, `config.yml` | Track and sandbox: 2 containers (Guacamole for RDP, AWS cloud-client), 8 VMs, 1 AWS account |
| `src/track_scripts/` | Per-host setup and cleanup templates |
| `src/challenges/` | The 8 challenges: assignment, check and solve scripts |
| `src/snippets/` | Shared check helpers and test-only VEN pairing, pasted in with `#@include` |
| `assets/app/` | Claims app (Flask, SQL Server), reporting job, Portal app (Flask, Postgres) |
| `assets/terraform/` | AWS Portal app: VPC, ALB, 2 web + 2 app EC2, RDS Postgres + replica, VPC flow logs to S3 |
| `assets/ipfix-gen/` | IPFIX exporter on kp-flow01, built from netflow_generator 0.2.8 |
| `assets/bin/` | Student helpers: `pov-connect`, `pce`, `preflight`, `kp` (SSM), `org-reset` |
| `assets/kestrel/` | Scoping sheet, label plan, answer sheet |

## Challenges

| # | Challenge | Checked on |
| --- | --- | --- |
| 1 | Review the scope and connect to the PCE | API works, Kestrel-POV pairing profile exists |
| 2 | Pre-flight checks | PASS on all 6 VMs and the 4 EC2 instances |
| 3 | Onboard AWS to CloudSecure | An IAM role or CloudFormation stack named "illumio" exists |
| 4 | VENs on 6 VMs, pair the NEN | 6 workloads online in visibility only, 1 NEN |
| 5 | VENs on 4 EC2 via SSM | 4 more workloads online in visibility only |
| 6 | Label and find | Labels match labels.csv, 3 answers right |
| 7 | Ringfence Claims and enforce | Ruleset active, web and DB in full, rpt01 blocked from 1433, app returns 200 |
| 8 | Readout | Success criteria filled with status and evidence |

## Between runs

`cleanup-kp-client01` runs `org-reset --yes` (unpairs VENs, deletes the POV rulesets, labels and
pairing profile) and then `terraform destroy`. Remove the AWS account from CloudSecure in the PCE by
hand if the org is reused. Unpair the NEN by hand as well.

## Verify on the first test run

These are written from documentation and could not be run here:

1. **Windows lifecycle scripts:** that Instruqt runs the extension-less PowerShell scripts on
   `instruqt/windows-server`, and that track secrets reach them as environment variables.
2. **SQL Express:** that the `sql-server-express` Chocolatey package installs SQL 2022 as
   `MSSQL16.SQLEXPRESS` (the registry path in `install-sql-express.ps1`).
3. **ncat for Windows:** the `ncat-portable-5.59BETA1.zip` URL on nmap.org.
4. **VEN pairing commands in the solve scripts:** the `/api/v25/software/ven/image?pair_script=...`
   format. Compare with what your PCE shows under Generate Key.
5. **NEN:** the `illumio-nen-ctl activate` flags, the IPFIX collector setup for UDP 4739 (the
   assignment points students at the NEN guide), and the `/network_enforcement_nodes` API used by
   the challenge 4 check.
6. **CloudSecure check:** the "illumio" name match on IAM roles and stacks is a heuristic.
7. **AWS env var case:** `setup-kp-client01` tries both `INSTRUQT_AWS_ACCOUNT_KESTREL_*` and
   `INSTRUQT_AWS_ACCOUNT_kestrel_*`.
8. **Full enforcement and Instruqt access:** challenge 7 adds lab rules for 22, 3389, 5985 inbound
   and DNS outbound so terminals and RDP keep working. Confirm no other port is needed.
9. **Terraform:** `terraform fmt` passes; `terraform validate` could not run here (no registry
   access). Run it once before the first push.

## Third-party

`assets/ipfix-gen` builds [netflow_generator](https://github.com/mikemiles-dev/netflow_generator)
0.2.8 from crates.io. Its LICENSE file is Apache-2.0 (the README says MIT).

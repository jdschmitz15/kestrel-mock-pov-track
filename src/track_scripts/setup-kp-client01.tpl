#!/bin/bash
# Learner's home base: helpers, scoping sheet, traffic generators, and the AWS Portal app.
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive
AWS_REGION="${AWS_REGION:-us-east-1}"   # change here to move the Portal app; must be in config.yml regions

apt-get update
apt-get install -y curl jq unzip python3 netcat-openbsd gnupg lsb-release cron

# AWS CLI v2, Session Manager plugin, Terraform
curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscli.zip
unzip -q -o /tmp/awscli.zip -d /tmp && /tmp/aws/install --update
curl -fsSL https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb -o /tmp/ssm.deb
dpkg -i /tmp/ssm.deb
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list
apt-get update && apt-get install -y terraform

# Lab files
#@bundle assets /opt/kestrel
install -m 0755 /opt/kestrel/bin/pce /opt/kestrel/bin/pov-connect /opt/kestrel/bin/kp /opt/kestrel/bin/org-reset /usr/local/bin/
install -m 0755 /opt/kestrel/bin/preflight.sh /usr/local/bin/preflight
mkdir -p /root/kestrel
cp -n /opt/kestrel/kestrel/scoping-sheet.md /opt/kestrel/kestrel/labels.csv /opt/kestrel/kestrel/answers.txt /root/kestrel/
echo "$AWS_REGION" > /opt/kestrel/aws-region

# AWS credentials for the learner's CLI (Instruqt injects them per account name)
v() { local n="INSTRUQT_AWS_ACCOUNT_KESTREL_$1"; local l="INSTRUQT_AWS_ACCOUNT_kestrel_$1"; echo "${!n:-${!l:-}}"; }
mkdir -p /root/.aws
cat > /root/.aws/credentials <<CREDS
[default]
aws_access_key_id = $(v AWS_ACCESS_KEY_ID)
aws_secret_access_key = $(v AWS_SECRET_ACCESS_KEY)
CREDS
printf '[default]\nregion = %s\n' "$AWS_REGION" > /root/.aws/config
chmod 600 /root/.aws/credentials

# Terraform: the Portal app (admin keys, only visible to lifecycle scripts)
export AWS_ACCESS_KEY_ID="$(v ADMIN_AWS_ACCESS_KEY_ID)" AWS_SECRET_ACCESS_KEY="$(v ADMIN_AWS_SECRET_ACCESS_KEY)"
[[ -n $AWS_ACCESS_KEY_ID ]] || { export AWS_ACCESS_KEY_ID="$(v AWS_ACCESS_KEY_ID)" AWS_SECRET_ACCESS_KEY="$(v AWS_SECRET_ACCESS_KEY)"; }
cd /opt/kestrel/terraform
terraform init -input=false
terraform apply -input=false -auto-approve -var "region=$AWS_REGION"
terraform output -json > /opt/kestrel/tf-outputs.json
ALB=$(jq -r .alb_dns.value /opt/kestrel/tf-outputs.json)
BUCKET=$(jq -r .flowlog_bucket.value /opt/kestrel/tf-outputs.json)
printf 'Portal URL: http://%s/\nFlow log bucket: %s\nAWS account: %s\nRegion: %s\n' \
  "$ALB" "$BUCKET" "$(jq -r .account_id.value /opt/kestrel/tf-outputs.json)" "$AWS_REGION" > /root/kestrel/aws-details.txt
agent variable set FLOWLOG_BUCKET "$BUCKET"
agent variable set PORTAL_URL "http://$ALB/"

# Traffic: users load the Claims app and the Portal twice a minute
cat > /usr/local/bin/kestrel-traffic <<TRAFFIC
#!/bin/bash
curl -s -o /dev/null --max-time 5 http://kp-web01/
curl -s -o /dev/null --max-time 5 http://$ALB/
TRAFFIC
chmod 755 /usr/local/bin/kestrel-traffic
cat > /etc/cron.d/kestrel-traffic <<'CRON'
* * * * * root /usr/local/bin/kestrel-traffic
* * * * * root sleep 30; /usr/local/bin/kestrel-traffic
CRON
systemctl enable --now cron

# Kestrel Point Portal app: ALB -> 2 web -> 2 app -> RDS Postgres (+ read replica).
# VPC flow logs (version 5, all fields) go to S3 for CloudSecure.
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

provider "aws" {
  region = var.region
  default_tags { tags = { Project = "kestrel-mock-pov" } }
}

data "aws_availability_zones" "azs" { state = "available" }
data "aws_caller_identity" "me" {}

locals {
  azs = slice(data.aws_availability_zones.azs.names, 0, 2)
}

# ---------- network ----------
resource "aws_vpc" "kp" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "kp-portal-vpc" }
}

resource "aws_internet_gateway" "kp" { vpc_id = aws_vpc.kp.id }

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.kp.id
  cidr_block              = "10.20.${count.index}.0/24"
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "kp-public-${count.index + 1}" }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.kp.id
  cidr_block        = "10.20.${count.index + 10}.0/24"
  availability_zone = local.azs[count.index]
  tags              = { Name = "kp-private-${count.index + 1}" }
}

resource "aws_subnet" "db" {
  count             = 2
  vpc_id            = aws_vpc.kp.id
  cidr_block        = "10.20.${count.index + 20}.0/24"
  availability_zone = local.azs[count.index]
  tags              = { Name = "kp-db-${count.index + 1}" }
}

resource "aws_eip" "nat" { domain = "vpc" }

resource "aws_nat_gateway" "kp" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.kp]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.kp.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kp.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.kp.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.kp.id
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# ---------- VPC flow logs, version 5, to S3 ----------
resource "aws_s3_bucket" "flowlogs" {
  bucket        = "kp-flowlogs-${data.aws_caller_identity.me.account_id}-${var.region}"
  force_destroy = true
}

resource "aws_flow_log" "kp" {
  vpc_id                   = aws_vpc.kp.id
  traffic_type             = "ALL"
  log_destination_type     = "s3"
  log_destination          = aws_s3_bucket.flowlogs.arn
  max_aggregation_interval = 60
  log_format = join(" ", [
    "$${version}", "$${account-id}", "$${interface-id}", "$${srcaddr}", "$${dstaddr}",
    "$${srcport}", "$${dstport}", "$${protocol}", "$${packets}", "$${bytes}", "$${start}",
    "$${end}", "$${action}", "$${log-status}", "$${vpc-id}", "$${subnet-id}", "$${instance-id}",
    "$${tcp-flags}", "$${type}", "$${pkt-srcaddr}", "$${pkt-dstaddr}", "$${region}", "$${az-id}",
    "$${sublocation-type}", "$${sublocation-id}", "$${pkt-src-aws-service}",
    "$${pkt-dst-aws-service}", "$${flow-direction}", "$${traffic-path}",
  ])
}

# ---------- security groups ----------
resource "aws_security_group" "alb" {
  name   = "kp-alb"
  vpc_id = aws_vpc.kp.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web" {
  name   = "kp-web"
  vpc_id = aws_vpc.kp.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app" {
  name   = "kp-app"
  vpc_id = aws_vpc.kp.id
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db" {
  name   = "kp-db"
  vpc_id = aws_vpc.kp.id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
}

# ---------- SSM access for EC2 ----------
resource "aws_iam_role" "ssm" {
  name = "kp-ec2-ssm"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = "sts:AssumeRole", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "kp-ec2-ssm"
  role = aws_iam_role.ssm.name
}

# ---------- images ----------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-${var.ubuntu_ami_date}*"]
  }
}

data "aws_ami" "rocky" {
  most_recent = true
  owners      = ["792107900819"] # Rocky Enterprise Software Foundation
  filter {
    name   = "name"
    values = ["Rocky-9-EC2-Base-9.*x86_64*"]
  }
}

# ---------- RDS Postgres + read replica ----------
resource "random_password" "db" {
  length  = 24
  special = false
}

resource "aws_db_subnet_group" "kp" {
  name       = "kp-portal-db"
  subnet_ids = aws_subnet.db[*].id
}

resource "aws_db_instance" "primary" {
  identifier              = "kp-portal-db"
  engine                  = "postgres"
  engine_version          = var.postgres_version
  instance_class          = "db.t4g.micro"
  allocated_storage       = 20
  db_name                 = "portal"
  username                = "portal"
  password                = random_password.db.result
  db_subnet_group_name    = aws_db_subnet_group.kp.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  backup_retention_period = 1 # required for a read replica
  skip_final_snapshot     = true
  apply_immediately       = true
}

resource "aws_db_instance" "replica" {
  identifier             = "kp-portal-db-ro"
  replicate_source_db    = aws_db_instance.primary.identifier
  instance_class         = "db.t4g.micro"
  vpc_security_group_ids = [aws_security_group.db.id]
  skip_final_snapshot    = true
  apply_immediately      = true
}

# ---------- app tier ----------
resource "aws_instance" "app" {
  count                  = 2
  ami                    = data.aws_ami.rocky.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.private[count.index].id
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm.name
  user_data = templatefile("${path.module}/userdata/app.sh.tftpl", {
    name          = "kp-papp0${count.index + 1}"
    db_host       = aws_db_instance.primary.address
    db_password   = random_password.db.result
    api_b64       = filebase64("${path.module}/files/portal_api.py")
    preflight_b64 = filebase64("${path.module}/files/preflight.sh")
  })
  tags = { Name = "kp-papp0${count.index + 1}", Role = "portal-app" }
}

# ---------- web tier ----------
resource "aws_instance" "web" {
  count                  = 2
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.private[count.index].id
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm.name
  user_data = templatefile("${path.module}/userdata/web.sh.tftpl", {
    name          = "kp-pweb0${count.index + 1}"
    app_ips       = aws_instance.app[*].private_ip
    preflight_b64 = filebase64("${path.module}/files/preflight.sh")
  })
  tags = { Name = "kp-pweb0${count.index + 1}", Role = "portal-web" }
}

# ---------- load balancer ----------
resource "aws_lb" "kp" {
  name               = "kp-portal-alb"
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "web" {
  name     = "kp-portal-web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.kp.id
  health_check { path = "/health" }
}

resource "aws_lb_target_group_attachment" "web" {
  count            = 2
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web[count.index].id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.kp.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

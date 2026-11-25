variable "region" {
  description = "AWS region for the Portal app. Must be in the track's aws_accounts regions list."
  type        = string
  default     = "us-east-1"
}

variable "ubuntu_ami_date" {
  description = "Pin the Ubuntu AMI by build date prefix (for example 2026) so a new image can't change the lab mid-cohort."
  type        = string
  default     = ""
}

variable "postgres_version" {
  description = "RDS Postgres engine version. Pin it between cohorts."
  type        = string
  default     = "16"
}

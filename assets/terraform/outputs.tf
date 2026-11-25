output "alb_dns" { value = aws_lb.kp.dns_name }
output "flowlog_bucket" { value = aws_s3_bucket.flowlogs.bucket }
output "rds_primary" { value = aws_db_instance.primary.address }
output "rds_replica" { value = aws_db_instance.replica.address }
output "account_id" { value = data.aws_caller_identity.me.account_id }
output "web_ips" { value = aws_instance.web[*].private_ip }
output "app_ips" { value = aws_instance.app[*].private_ip }

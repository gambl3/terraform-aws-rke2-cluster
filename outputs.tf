output "timestamp" {
  value       = [timestamp()]
  description = "Create/Update Timestamp"
}

output "instance_ips_control" {
  value       = [aws_instance.aws_ec2_instance_control.*.private_ip]
  description = "IPs for the Control Node in the AWS RKE2 cluster"
}

output "instance_ips_worker" {
  value       = [aws_instance.aws_ec2_instance_worker.*.private_ip]
  description = "IPs for the Worker Nodes in the AWS RKE2 cluster"
}

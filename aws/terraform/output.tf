output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "elb_public_dns_name" {
  value = ["${aws_elb.elb.dns_name}"]
}
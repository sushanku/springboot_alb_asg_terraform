output "alb_dns" {
  value = aws_lb.terraform-lab.dns_name
}
output "alb_zone" {
  value = aws_lb.terraform-lab.zone_id
}
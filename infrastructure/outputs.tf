#---------------------------------------
# ALB DNS Hostname
#---------------------------------------
output "alb_dns_name" {
    value = module.alb.alb_dns_name
}

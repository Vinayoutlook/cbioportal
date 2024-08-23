# Receiving traffic from all over and routing it to private subnet
resource "aws_lb" alb {
  name               = "${local.prefix}-alb" # <env>-platform-ecbio-alb
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.account == "dpp" || var.account == "dpnp" ? concat(local.vpn_sg_ids, local.alb_sg_id): concat(local.alb_sg_id, local.vpn_sg_ids,local.cbio_sg_id)
  subnets            = nonsensitive(split(",", data.aws_ssm_parameter.public_subnet_ids.value))
  idle_timeout       =  300
  access_logs {
    bucket  = data.aws_ssm_parameter.s3_logging_id.value
    prefix  = "alb/${local.prefix}-alb"  # alb/<env>-platform-ecbio-alb
    enabled = true
  }

  tags = merge(local.tags,
    local.compliance,{
    Name        = "${local.prefix}-alb" # <env>-platform-ecbio-alb
  })
}

# Listener to receive traffic at 443
resource "aws_lb_listener" alb_listener_443 {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  certificate_arn   = nonsensitive(data.aws_ssm_parameter.certificate_arn.value)

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not Found"
      status_code  = "404"
    }
  }

  # Ensure listener is destroyed before target groups
  depends_on = [aws_lb.alb, aws_lb_target_group.alb_target]
}

#Target group to the cbio services.
resource "aws_lb_target_group" alb_target {
  for_each    = toset(local.client_list)
  name        = "${local.prefix}-${each.key}-tg" #    dev-platform-ecbio-hospital1-tg
  port        = local.cbioportal.container_port
  protocol    = "HTTP"
  vpc_id      = nonsensitive(data.aws_ssm_parameter.vpc_id.value)
  target_type = "ip"
  stickiness {
    type = "lb_cookie"
    enabled = true
    cookie_duration = 604800
  }
  health_check {
    enabled  = true
    protocol = "HTTP"
    path     = "/${each.key}${local.cbioportal.health_check}"
  }

  tags = merge(local.tags,local.compliance,{
    Name = "${local.prefix}-${each.key}-core-tg"
  })

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb.alb]
}

# #Adding listener rule to block API calls
# resource "aws_lb_listener_rule" block_api_call {
#   listener_arn = aws_lb_listener.alb_listener_443.arn
#   priority = 1
#   condition {
#     path_pattern {
#       values = ["*swagger*"]
#     }
#   }
#   action {
#     type = "fixed-response"
#
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "You are not allowed to access this URL. The attempt will be reported."
#       status_code  = "503"
#     }
#   }
#
#   # Ensure listener rules are destroyed before target groups
#   depends_on = [aws_lb_target_group.alb_target]
# }

# Listener rule for API calls for each client
resource "aws_lb_listener_rule" client_routing {
  for_each     = toset(local.client_list)
  listener_arn = aws_lb_listener.alb_listener_443.arn
  priority = index(local.client_list, each.key) + 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target[each.key].arn
  }
  condition {
    path_pattern {
      values = ["*/${each.key}*"]
    }
  }

  # Ensure listener rules are destroyed before target groups
  depends_on = [aws_lb.alb, aws_lb_target_group.alb_target]
}


# Route53 record for DNS resolution.
resource "aws_route53_record" route53_record {
  zone_id = data.aws_ssm_parameter.data_zone_id.value
  name    = "${var.env}.nexus"                 # Final URL <env>.nexus.npdata.guardanthealth.com
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

# Gateway to access keycloak admin portal.
resource "aws_lb" kc_alb {
  name               = "${local.prefix}-keycloak-alb" # <env>-platform-ecbio-keycloak-alb
  internal           = false
  load_balancer_type = "application"
  # This security group will not give public access
  security_groups    = var.account == "dpp" || var.account == "dpnp" ? concat(local.vpn_sg_ids, local.alb_sg_id):concat(local.alb_sg_id, local.vpn_sg_ids ,local.cbio_sg_id)
  subnets            = nonsensitive(split(",", data.aws_ssm_parameter.public_subnet_ids.value))

  access_logs {
    bucket  = data.aws_ssm_parameter.s3_logging_id.value
    prefix  = "alb/${local.prefix}-keycloak-alb"
    enabled = true
  }

  tags = merge(local.tags,local.compliance,{
    Name        = "${local.prefix}-keycloak-alb"
  })
}

# Listener for receiving traffic at 443.
resource "aws_lb_listener" alb_listener_kc_80 {
  load_balancer_arn = aws_lb.kc_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  certificate_arn   = nonsensitive(data.aws_ssm_parameter.certificate_keycloak_arn.value)

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_keycloak.id
  }
}

locals {
  vpn_cidrs = split(",",data.aws_ssm_parameter.vpn_external_cidrs.value)
}

# Listener rule for the accessing keycloak with in VPN for administration
resource "aws_lb_listener_rule" allow_alb_kc_vpn {
  count          = length(local.vpn_cidrs)
  listener_arn = aws_lb_listener.alb_listener_kc_80.arn
  priority = 1 + count.index
  condition {
    source_ip {
      values = [local.vpn_cidrs[count.index]]
    }
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alb_target_keycloak.arn
  }
  tags = merge(local.tags,
    local.compliance,{
      Name        = "Allow_VPN_swg+${count.index}"
    })
}
# Listener rule for accessing the Admin api keycloak
resource "aws_lb_listener_rule" block_alb_kc_admin {
  //pattern = var.account == "dpp" || var.account == "dpnp" ? []:["*/admin*"]
  listener_arn = aws_lb_listener.alb_listener_kc_80.arn
  priority = 100
  condition {
    path_pattern {
      values = ["/admin*"]
    }
  }
  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Access blocked for Admin"
      status_code  = "401"
    }
  }
  tags = merge(local.tags,
    local.compliance,{
      Name        = "Block_Admin"
    })
}
# Target group to the keycloak services.
resource "aws_lb_target_group" alb_target_keycloak {
  name        = "${local.prefix}-keycloak-tg"
  port        = local.keycloak.container_port
  protocol    = "HTTP"
  vpc_id      = nonsensitive(data.aws_ssm_parameter.vpc_id.value)
  target_type = "ip"

  health_check {
    enabled = true
    protocol            = "HTTP"
    path                = local.keycloak.health_check
  }

  tags = merge(local.tags,local.compliance,{
    Name = "${local.prefix}-keycloak-tg"
  })
  depends_on = [aws_lb.kc_alb]
}

# Route53 record for DNS resolution.
resource "aws_route53_record" route53_kc_record {
  zone_id = data.aws_ssm_parameter.data_zone_id.value
  name    = "${var.env}.${local.keycloak.component}" # Final URL <env>.keycloak.npdata.guardanthealth.com
  type    = "A"

  alias {
    name                   = aws_lb.kc_alb.dns_name
    zone_id                = aws_lb.kc_alb.zone_id
    evaluate_target_health = true
  }
}

# module "alb-ecbioportal-service-availability" {
#   source       = "./.dependencies/terraform-aws-gh-dp-glue/alb/alb-common-monitoring"
#   # e.g. alb_name = app/dpnp-platform-ecbio-alb/id
#   alb_name     = aws_lb.alb.arn_suffix
#   account      = var.account
#   env          = var.env
#   component    = local.Component
#   data_product = local.DataProduct
#
#   monitoring = {
#     ### Service Availability Monitoring
#     httpcode_elb_5xx_count = {
#       period                          = 300
#       greater_than_threshold          = 0
#     }
#     rejected_connection_count = {
#       period                          = 300
#       greater_than_threshold          = 0
#     }
#     httpcode_elb_4xx_count = {
#       period                          = 600
#       greater_than_threshold          = 0
#     }
#   }
# }

# module "alb-ecbioportal-service-quality" {
#   source       = "./.dependencies/terraform-aws-gh-dp-glue/alb/alb-target-monitoring"
#   # e.g. alb_name = app/dpnp-platform-ecbio-alb/id
#   alb_name     = aws_lb.alb.arn_suffix
#   # e.g. target_group_name = targetgroup/dpnp-platform-ecbio-core-tg/id
#   target_group_name = aws_lb_target_group.alb_target[local.vendor_list[0]].arn_suffix
#   account      = var.account
#   env          = var.env
#   component    = local.Component
#   data_product = local.DataProduct
#
#   monitoring = {
#     ### Service Quality Monitoring
#     healthy_host_count = {
#       period                          = 300
#       less_than_threshold             = 1
#     }
#     avg_target_response_time = {
#       period                          = 600
#       greater_than_threshold          = 95
#     }
#     unhealthy_host_count = {
#       period                          = 600
#       greater_than_threshold          = 0
#     }
#     httpcode_target_5xx_count = {
#       period                          = 600
#       greater_than_threshold          = 0
#     }
#     target_connection_error_count = {
#       period                          = 600
#       greater_than_threshold          = 0
#     }
#   }
# }
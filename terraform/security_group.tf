# Creating security group for load balancer.
resource "aws_security_group" alb_security_group {
  name        = "${local.prefix}-alb"
  description = "${local.prefix} alb security group"
  vpc_id      = nonsensitive(data.aws_ssm_parameter.vpc_id.value)
  ingress {
    description     = "Adding self rule"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    self            = true
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.tags,local.compliance,{
    Name        = "${local.prefix}-alb"
  })
}

resource "aws_security_group_rule" "allow_https"{
  type                     = "ingress"
  security_group_id        = aws_security_group.alb_security_group.id
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "tcp"
  cidr_blocks              = [ for v in data.aws_nat_gateway.nat_gw : format("${v.public_ip}%s", "/32") ]
}

# Creating security for the resources.
# This security group used across all the resources like ECS,RDS,Elastic-Cache,DocumentDB.
resource "aws_security_group" cbio_ecs_security_group {
  name = "${local.prefix}-sg"
  vpc_id = nonsensitive(data.aws_ssm_parameter.vpc_id.value)

  ingress {
    description     = "Adding self rule"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    self            = true
  }
  ingress {
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
    from_port       = 8080
    to_port         = 8080
    description     = "All traffic Communication channel With ALB."
  }
  ingress {
    protocol        = "all"
    security_groups = [data.aws_security_group.compute_environment.id]
    from_port       = 0
    to_port         = 0
    description     = "All traffic from AWS batch compute environment"
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "Internet connection"
  }

  tags = merge(local.tags,local.compliance, {
    Name = "${local.prefix}-sg"
  })
}

# Create security group for internet access in aws external account
# This security group used only for external account load balancers ecbio & keycloak
resource "aws_security_group" cbio_external_security_group {
  name = "${local.prefix}-external-sg"
  vpc_id = nonsensitive(data.aws_ssm_parameter.vpc_id.value)
  count = var.account == "dpp" || var.account == "dpnp" ? 0 : 1

  ingress {
    description     = "Adding self rule"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    self            = true
  }
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "Internet connection"
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "Internet connection"
  }

  tags = merge(local.tags,local.compliance, {
    Name = "${local.prefix}-external-sg"
  })
}

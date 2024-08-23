locals {
  ecs_keycloak_prefix = "${local.prefix}-keycloak" # <env>-platform-ecbio-keycloak
}

# ECS Fargate container for keycloak service.
resource "aws_ecs_service" "ecs_keycloak" {
  name                               = local.ecs_keycloak_prefix # <env>-platform-ecbio-keycloak
  cluster                            = aws_ecs_cluster.cbio_cluster.id
  task_definition                    = aws_ecs_task_definition.ecs_keycloak_task_definition.arn
  desired_count                      = local.keycloak.service_desired_count
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  platform_version                   = "1.4.0"
  enable_execute_command             = true

  service_registries {
    registry_arn = aws_service_discovery_service.ecs_keycloak_service_discovery.arn
    container_name = local.keycloak.component
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_keycloak.arn
    container_name   = local.ecs_keycloak_prefix
    container_port   = local.keycloak.container_port
  }

  network_configuration {
    security_groups  = [aws_security_group.cbio_ecs_security_group.id]
    subnets          = local.private_subnets
    assign_public_ip = false
  }

  tags = merge(local.tags,local.compliance,{
    Name  = local.ecs_keycloak_prefix
  })
}

# ECS Fargate container for keycloak task definition.
resource "aws_ecs_task_definition" "ecs_keycloak_task_definition" {
  family                   = local.ecs_keycloak_prefix
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.ecs.container_cpu
  memory                   = local.ecs.container_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions    = data.template_file.keycloak_task_definition.rendered

  tags = merge(local.tags,local.compliance,{
    Name  = "${local.ecs_keycloak_prefix}-task-definition"
  })
}

# Service registration for the keycloak in cloud map
resource "aws_service_discovery_service" "ecs_keycloak_service_discovery" {
  name = local.keycloak.component
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.ns.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

# module "ecs-ecbio-keycloak-service-quality" {
#   source                      = "./.dependencies/terraform-aws-gh-dp-glue/ecs/ecs-common-monitoring"
#   cluster_name                = "${local.prefix}-cluster" # <env>-platform-ecbio-cluster
#   service_name                = "${local.prefix}-keycloak" # <env>-platform-ecbio-keycloak
#   account                     = var.account
#   env                         = var.env
#   component                   = local.Component
#   data_product                = local.DataProduct
#
#   monitoring = {
#     ### Service Level Monitoring
#     avg_cpu_utilization_high = {
#       period                          = 600
#       greater_than_or_equal_to_threshold = 70
#     }
#     avg_cpu_utilization_low = {
#       period                          = 600
#       less_than_or_equal_to_threshold = -1
#     }
#     avg_memory_utilization_high = {
#       period                          = 600
#       greater_than_or_equal_to_threshold = 80
#     }
#     avg_memory_utilization_low = {
#       period                          = 600
#       less_than_or_equal_to_threshold = -1
#     }
#   }
# }

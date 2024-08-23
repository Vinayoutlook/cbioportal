locals {
  ecs_cbio_prefix      = "${local.prefix}-portal" # <env>-platform-ecbio-portal
}

# Use local.vendor_list to create the ECS service for each vendor
# ECS Fargate container for cbio service.
resource "aws_ecs_service" ecs_cbio_service {
  for_each                           = toset(local.client_list)
  name                               = "${each.key}-${local.ecs_cbio_prefix}" # <client>-<env>-platform-ecbio-portal
  cluster                            = aws_ecs_cluster.cbio_cluster.id
  task_definition                    = aws_ecs_task_definition.cbio_task_definition[each.key].arn
  desired_count                      = local.cbioportal.service_desired_count
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  platform_version                   = "1.4.0"
  enable_execute_command             = true

  service_registries {
    registry_arn   = aws_service_discovery_service.ecs_cbio_service_discovery[each.key].arn
    container_name = "${each.key}-${local.ecs_cbio_prefix}"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target[each.key].arn
    container_name   = "${each.key}-${local.ecs_cbio_prefix}"
    container_port   = local.cbioportal.container_port
  }

  network_configuration {
    security_groups  = [aws_security_group.cbio_ecs_security_group.id]
    subnets          = local.private_subnets
    assign_public_ip = false
  }

  tags = merge(local.tags,local.compliance, {
    Name = "${each.key}-${local.ecs_cbio_prefix}"
  })
}

# ECS Fargate container for cbio task definition.
resource "aws_ecs_task_definition" cbio_task_definition {
  for_each                 = toset(local.client_list)
  family                   = "${each.key}-${local.ecs_cbio_prefix}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.cbioportal.container_cpu
  memory                   = local.cbioportal.container_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions    = var.account == "dpep" || var.account == "dpenp" ? data.template_file.cbioportal_task_definition_ext[each.key].rendered : data.template_file.cbioportal_task_definition[each.key].rendered

  tags = merge(local.tags,local.compliance, {
    Name = "${local.ecs_cbio_prefix}-task-definition"
  })
}

# Use local.vendor_list to create the ECS service for each vendor
# Registering cbio service in cloud map
resource "aws_service_discovery_service" ecs_cbio_service_discovery {
  for_each = toset(local.client_list)
  name = "${each.key}-${local.ecs_cbio_prefix}"
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

# # Use local.vendor_list to create the ECS service for each vendor
# #Auto scaling
# resource "aws_appautoscaling_target" "ecbioportal_autoscale" {
#   for_each     = toset(local.vendor_list)
#   max_capacity = local.cbioportal.max_tasks
#   min_capacity = local.cbioportal.service_desired_count
#   resource_id = "service/${aws_ecs_cluster.cbio_cluster.name}/${aws_ecs_service.ecs_cbio_service[each.key].name}"
#   scalable_dimension = "ecs:service:DesiredCount"
#   service_namespace = "ecs"
# }
# resource "aws_appautoscaling_policy" "ecbioportal_autoscalepolicy_cpu" {
#   for_each           = toset(local.vendor_list)
#   name               = "${each.key}-${local.prefix}-portal-autoscaling-policy-cpu"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = "service/${aws_ecs_cluster.cbio_cluster.name}/${aws_ecs_service.ecs_cbio_service[each.key].name}"
#   scalable_dimension = aws_appautoscaling_target.ecbioportal_autoscale[each.key].scalable_dimension
#   service_namespace  = aws_appautoscaling_target.ecbioportal_autoscale[each.key].service_namespace
#
#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageCPUUtilization"
#     }
#     target_value       = local.cbioportal.autoscale_average_cpu_limit
#   }
# }
#
# resource "aws_appautoscaling_policy" "ecbioportal_autoscalepolicy_mem" {
#   for_each           = toset(local.vendor_list)
#   name               = "${each.key}-${local.prefix}-portal-autoscaling-policy-mem"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = "service/${aws_ecs_cluster.cbio_cluster.name}/${aws_ecs_service.ecs_cbio_service[each.key].name}"
#   scalable_dimension = aws_appautoscaling_target.ecbioportal_autoscale[each.key].scalable_dimension
#   service_namespace  = aws_appautoscaling_target.ecbioportal_autoscale[each.key].service_namespace
#
#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageMemoryUtilization"
#     }
#     target_value       = local.cbioportal.autoscale_average_mem_limit
#   }
# }
#
# # Use local.vendor_list to create the ECS service for each vendor
# module "ecs-ecbioportal-service-quality" {
#   for_each                    = toset(local.vendor_list)
#   source                      = "./.dependencies/terraform-aws-gh-dp-glue/ecs/ecs-common-monitoring"
#   cluster_name                = "${local.prefix}-cluster" # dpnp-platform-ecbio-cluster
#   service_name                = "${each.key}-${local.prefix}-portal" # dpnp-platform-ecbio-portal
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
#


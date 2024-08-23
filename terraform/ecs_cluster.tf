# ECS cluster for fargate containers.
resource aws_ecs_cluster cbio_cluster {
  name = "${local.prefix}-cluster"  # <env>-platform-ecbio-cluster
  #capacity_providers = ["FARGATE"]

  setting {
    name = "containerInsights"
    value = "enabled"
  }

  tags = merge(local.tags,local.compliance,{
    Name  = "${local.prefix}-cluster"
  })
}


module "ecs-ecbioportal-service-availability" {
  source                      = "./.dependencies/terraform-aws-gh-dp-glue/ecs/ecs-cluster-monitoring"
  cluster_name                = "${local.prefix}-cluster" # dev-platform-ecbio-cluster
  account                     = var.account
  env                         = var.env
  component                   = local.Component
  data_product                = local.DataProduct

  monitoring = {
    ### Cluster Level Monitoring
    container_instance_count = {
      period                          = 300
      less_than_or_equal_to_threshold = 0
    }
    task_count = {
      period                          = 300
      less_than_or_equal_to_threshold = 0
    }
  }
}




# TASK ROLE AND ITS POLICIES
# Policy Documents for Task Role
data aws_iam_policy_document ecs_task_policy {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"]
    resources = ["*"] # To exec in container these are permissions which are minimal
    #https://awspolicygen.s3.amazonaws.com/policygen.html
  }
}

data aws_iam_policy_document ecs_task_role {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
    }
    effect = "Allow"
  }
}

# Policy and Role for Task Role
resource "aws_iam_policy" "ecs_task_policy" {
  name        = "${local.prefix}-task-policy"
  description = "Policy attached to task role"
  policy = data.aws_iam_policy_document.ecs_task_policy.json
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${local.prefix}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role.json
  tags = merge(local.tags,local.compliance,{
    Name  = "${local.prefix}-task-role"
  })
}

# Attaching Policy and role for Task Role
resource "aws_iam_role_policy_attachment" "ecs_task_role_attachment_1" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}


# TASK EXECUTION ROLE AND ITS POLICIES
# ECS Task Execution role
data aws_iam_policy_document ecs_task_execution_role {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
    }
    effect = "Allow"
  }
}
data aws_iam_policy_document ecs_task_execution_policy {
  statement {
    sid = "GetParameters"
    effect = "Allow"
    actions = [
      "ssm:GetParameter"
    ]
    resources = ["*"]
  }

  statement {

    effect = "Allow"
    sid = "GetSecretsForCBIO"

    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = ["*"]
  }
}

# ECS containers ability to send logs to cloudwatch
resource "aws_iam_policy" "ecs_task_execution_policy" {
  name        = "${local.prefix}-task-execution-policy"
  description = "Policy that execution role to access secrets"
  policy = data.aws_iam_policy_document.ecs_task_execution_policy.json
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${local.prefix}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json

  tags = merge(local.tags,local.compliance,{
    Name  = "${local.prefix}-task-execution-role"
  })
}

# ECS - granting permissions(policy) to the role
resource "aws_iam_role_policy_attachment" "execution_role_attachment_1" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}

resource "aws_iam_role_policy_attachment" "execution_role_attachment_2" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Provides a local DNS lookup for the services in a container.
resource "aws_service_discovery_private_dns_namespace" "ns" {
  name          = "${local.prefix}-ns"
  description   = "Name space for ${var.account} CBIO Portal"
  vpc           = data.aws_ssm_parameter.vpc_id.value

  tags = merge(local.tags, local.compliance,{
    Name  = "${local.prefix}-ns"
  })
}
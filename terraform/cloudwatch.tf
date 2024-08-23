# Log group created for all the resources
resource "aws_cloudwatch_log_group" logs {
  name              = "${local.prefix_path}/logs" # <env>/platform/ecbio/logs
  retention_in_days = local.ecs.log_retention_days

  tags              = merge(var.tags,local.compliance,{
    Name        = "${local.prefix}-logs" # <env>-platform-ecbio-logs
  })
}

# Creating the policy for the logs.
data "aws_iam_policy_document" logs_policy {
  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
      "logs:CreateLogStream"
    ]

    resources = ["${aws_cloudwatch_log_group.logs.arn}:*"]

    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
  }
}

# Attaching the policy for the log group.
resource "aws_cloudwatch_log_resource_policy" cbio_logs {
  policy_name = "/${local.prefix_path}/policy"
  policy_document = data.aws_iam_policy_document.logs_policy.json
}

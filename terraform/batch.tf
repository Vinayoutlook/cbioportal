module "ecbio_batch_job" {

  source = "./.dependencies/terraform-aws-gh-dp-glue/batch"

  aws_region = var.aws_region
  account = var.account
  env = var.env
  log_group_id = module.service-role.gh_dp_data_asset_log_group_id
  data_product = local.DataProduct
  component = local.Component
  service_role_arn = module.service-role.gh_dp_data_asset_role

  command = ["/bin/sh","-c","/cbioportal/data_load.sh"]
  image = "${data.aws_ecr_repository.ecbio-repo.repository_url}:latest"

#  memory = var.account == "dpenp" || var.account == "dpep" ? "16384" : "32768"
#  vcpu = var.account == "dpenp" || var.account == "dpep" ? "2" : "8"

  memory = "61440"
  vcpu = "8"

  secrets = [
    {
      "name" = "DB_USER",
      "valueFrom" = data.aws_secretsmanager_secret_version.cbiords_username.arn
    },
    {
      "name" = "DB_PASSWORD",
      "valueFrom" = data.aws_secretsmanager_secret_version.cbiords_password.arn
    }
    ]

  environment = [
    {
      "name" = "account",
      "value" = var.account
    },
    {
      "name" = "env",
      "value" = var.env
    },
    {
      "name" = "DB_HOST",
      "value" = "${module.aws_rds_cluster.endpoint}:${local.database.rds_port}"
    },
    {
      "name" = "DB_CONNECTION_STRING",
      "value" = var.account == "dpenp" || var.account == "dpep" ? "jdbc:${local.rds.rds_type}://${module.aws_rds_cluster.endpoint}:${local.database.rds_port}/" : "jdbc:mysql://${module.aws_rds_cluster.endpoint}:${local.database.rds_port}/${local.rds.cbiords_dbname}?useSSL=false"
    },
    {
      "name" = "DB_USE_SSL",
      "value" = "false"
    },
    {
      "name" = "PORTAL_DB_NAME",
      "value" = local.rds.cbiords_dbname
    },
    {
      "name" = "DB_DRIVER",
      "value" = local.database.db_driver
    },
    {
      "name" = "ENDPOINT"
      "value" = local.redis.cache_endpoint_key
    }
  ]
}

# Defining access to S3 from AWS batch.
data aws_iam_policy_document access_to_aws_batch{
  statement {
    effect = "Allow"
    actions = ["s3:*"]
    resources = ["*"]
  }
  statement {
    effect  = "Allow"
    actions = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }
  statement {
    effect  = "Allow"
    actions = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }
  statement {
    effect  = "Allow"
    actions = ["ssm:GetParameter"]
    resources = ["*"]
  }
}

resource aws_iam_policy access_to_aws_batch {
  name = "${local.prefix}-access_to_aws_batch"
  policy = data.aws_iam_policy_document.access_to_aws_batch.json
}

resource "aws_iam_role_policy_attachment" s3_access_to_batch_attachment {
  role       = module.service-role.gh_dp_data_asset_role_name
  policy_arn = aws_iam_policy.access_to_aws_batch.arn
}


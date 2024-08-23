data "archive_file" "cbio-sanity" {
  type        = "zip"
  source_dir  = "${path.module}/../canaries/ecbio-sanity"
  output_path = "${path.module}/../canaries/ecbio-sanity.zip"
}

resource "aws_s3_bucket_object" "file_upload" {
  bucket = module.data-asset-s3.data_asset_bucket
  key    = "canary/cbio-sanity.zip"
  source = data.archive_file.cbio-sanity.output_path
  etag   = filemd5(data.archive_file.cbio-sanity.output_path)
}

module "cbio-sanity" {

  canary_name         = "${local.Component}-sanity"
  source              = "./.dependencies/terraform-aws-gh-dp-glue/cloudwatch/canary"
  zip_file            = "${path.module}/../canaries/ecbio-sanity.zip"
  runtime_version     = "syn-python-selenium-2.1"

  env                 = var.env
  account             = var.account
  aws_region          = var.aws_region
  component           = local.Component
  data_product        = var.data_product
  s3_bucket_name      = module.data-asset-s3.data_asset_bucket
  service_role_arn    = module.service-role.gh_dp_data_asset_role
  schedule_expression = "rate(10 minutes)"

  subnet_ids          = local.private_subnets
  security_group_ids  = split(",", aws_security_group.alb_security_group.id)

  depends_on = [ aws_s3_bucket_object.file_upload ]
}
# Creating S3 bucket
//TODO - we should have a type - "platform"
// TODO - We should have name and component separate.

provider "aws" {
  alias = "external"
  region  = var.aws_region
  assume_role {
    role_arn = var.supported_env_jenkins_role_arn
    session_name = "terraform_jenkins_session"
  }
}

module "data-asset-s3" {
  source               = "./.dependencies/terraform-aws-gh-dp-glue/s3"
  aws_region           = var.aws_region
  env                  = var.env
  data_product         = var.data_product
  component            = "data-asset"
  account              = var.account
  bucket_object_ownership = "BucketOwnerEnforced"
  additional_role_access_to_s3 = var.account == "dpep" || var.account == "dpenp" ? [local.internal_role_arn]: []
  compliance           = merge(local.compliance , {
    PHI_PII_Information = "Yes"
  })
}

# Creating studies folder inside s3 bucket.
resource "aws_s3_bucket_object" "studies-folder" {
  bucket = module.data-asset-s3.data_asset_bucket
  acl    = "private"
  key    = "studies/"
  source = "/dev/null"
}

# Service role for all data assets access
module "service-role" {
  source                        = "./.dependencies/terraform-aws-gh-dp-glue/service-role"
  aws_region                    = "us-west-2"
  env                           = var.env
  data_product                  = local.DataProduct
  component                     = "${local.Component}-iam"
  account                       = var.account
  data_asset_s3_arn             = module.data-asset-s3.data_asset_bucket_arn
  additional_databases          = []
  additional_databases_v2       = []
  additional_data_asset_s3_arns = []

  ssm_parameter_components = [local.Component]
  secrets_manager_components = [local.Component]
}

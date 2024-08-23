# Creating EFS for the AWS batch job.
# Copying studies from s3 and placing it in /efs/studies.Aws batch load the studies from the /efs/studies.
# TODO : EFS will be replaced with EBS
# No need of backup as this is a temporary location
resource "aws_efs_file_system" this {
  creation_token = "${local.prefix}-efs" # <env>-platform-ecbio-efs
  encrypted = true
  kms_key_id = aws_kms_key.cbio_kms_key.arn
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  provisioned_throughput_in_mibps = null //may be it should be 0

   lifecycle_policy {
      transition_to_ia = "AFTER_7_DAYS"
  }

  tags = merge(local.tags,local.compliance,{
    Name = "${local.prefix}-efs"
  })
}

# Mounting target for the container
resource "aws_efs_mount_target" this {
  for_each = { for subnet in split(",", nonsensitive(data.aws_ssm_parameter.private_subnet_ids.value)) : subnet => true }
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.key
  security_groups = [aws_security_group.cbio_ecs_security_group.id]
}

# module "efs-ecbioportal-service-quality" {
#   source       = "./.dependencies/terraform-aws-gh-dp-glue/efs/efs-common-monitoring"
#   efs_id       = aws_efs_file_system.this.id # <env>-platform-ecbio-filesystem_id
#   account      = var.account
#   env          = var.env
#   component    = local.Component
#   data_product = local.DataProduct
#
#   monitoring = {
#     ### Service Availability Monitoring
#     client_connections = {
#       period                  = 300
#       less_than_or_equal_to_threshold     = 0
#     }
#
#     ### Service Quality Monitoring
#     percent_io_limit = {
#       period                  = 600
#       greater_than_threshold  = 80
#     }
#     permitted_throughput = {
#       period                  = 600
#       less_than_threshold     = 50
#     }
#   }
# }





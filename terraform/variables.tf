locals {
  DataProduct = "platform"
  Component   = "ecbio"

  tags = {
    map-migrated    = data.aws_ssm_parameter.map.value
    Environment     = var.env
    DataProduct     = local.DataProduct
    Component       = local.Component
  }
#  cbio_prefix_path = "${var.env}/${local.DataProduct}/${local.cbio.Component}"

  prefix      = "${var.env}-${local.DataProduct}-${local.Component}" # dev-platform-ecbio
  prefix_path = "${var.env}/${local.DataProduct}/${local.Component}"
  #prefix_account_path = "${var.account}/${local.DataProduct}/${local.Component}"
  route53_domain_name = "data.guardanthealth.com"

  private_subnets = nonsensitive(split(",", data.aws_ssm_parameter.private_subnet_ids.value))
  public_subnets = nonsensitive(split(",", data.aws_ssm_parameter.public_subnet_ids.value))

  ecs = {
    container_cpu = 4096
    container_memory = 30720
    service_desired_count = 1
    log_retention_days = 0
  }

  keycloak = {
    health_check = "/health"
    container_image  = "quay.io/keycloak/keycloak:20.0.1"
    container_port   = 8080
    component = "keycloak"
    engine_version = "5.7.mysql_aurora.2.11.5"
    instance_class = "db.t3.medium"
    service_desired_count = 1
    max_tasks = 3
    autoscale_average_cpu_limit = 70
    autoscale_average_mem_limit = 80
  }

  session = {
    container_image   = "cbioportal/session-service:0.5.0"
    container_port    = 5000
    component = "session"
    service_desired_count = 1
    max_tasks = 3
    autoscale_average_cpu_limit = 70
    autoscale_average_mem_limit = 80
  }

  cbioportal ={
    container_port = 8080
    health_check = "/api/health"
    Component = "cbio"
    container_cpu = 16384
    container_memory = 90112
    service_desired_count = 1
    max_tasks = 10
    autoscale_average_cpu_limit = 20
    autoscale_average_mem_limit = 30
  }

  database = {
    docdb_port = 27017
    rds_port = 3306
    redis_port = 6379
    db_driver = "com.mysql.jdbc.Driver"
  }

  rds = {
    rds_type  = "mysql"
    engine    = "aurora-mysql"
    engine_version = "8.0.mysql_aurora.3.05.2"
    instance_class = "db.x2g.xlarge"
    parameter_group_family = "aurora-mysql8.0"
    cbiords_dbname = "cbiodb"
    kcrds_dbname = "kcdb"
  }

  redis = {
    instance_type  = "cache.r6g.xlarge"
    encription_enabled = true
    clusters_count = 2
    cache_type = "redis"
    cache_endpoint_key = "c7a34f4b-36dc-42c3-8857-8755506a5c04"
  }
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  compliance = {
    Description          = "This resource added for ecbio portal ",
    PHI_PII_Information  = "Yes",
    Public_Accessibility = "No",
    Expiry_Date          = "NA",
    Department           = "DataPlatform",
    Cost_Center          = "N/A",
    Tech_Team            = "DataPlatform",
    Tech_Owner           = "Datta Sawale",
    CR_Ticket_Number     = "EPPE-2102"
  }
}

variable aws_region {
  type = string
  description = "aws region"
  default = "us-west-2"
}

variable "account" {
  type        = string
  description = "This is the account where your infrastructure example - dpp, dpnp, dps"
//  default     = "dpnp"
}

variable "env" {
  type        = string
  description = "This is the workspace where we will be creating the resource."
//  default     = "dev"
}

variable data_product {
  type = string
  default = "ecbio"
}

variable route53_create_alias {
  type    = string
  default = true
}

variable route53_alias_name {
  type    = string
  default = "ecbio"
}

variable "tags" {
  description = "Optional map of tags to set on resources, defaults to empty map."
  type        = map(string)
  default     = {}
}

variable "ca_cert_identifier" {
  description = "Specifies the identifier of the CA certificate for the DB instance"
  type        = string
  default     = null
}

resource "aws_kms_key" "cbio_kms_key" {
  description = "KMS key used to encrypt Jenkins EFS volume"
  enable_key_rotation = true
}

variable efs_enable_backup {
  type    = bool
  default = true
}

variable "recovery_window_in_days" {
  type = number
  default = 30
}

variable "supported_env_jenkins_role_arn" {
  type = string
  default = ""
}

locals {
  role = jsondecode(file("${path.module}/s3_policy_conf.json"))
  internal_role_arn = local.role[var.account][var.env]["role_arn"]
}

locals {
  vpn_sg_ids = tolist(split(",", data.aws_ssm_parameter.vpn_sg.value))
  alb_sg_id = tolist([aws_security_group.alb_security_group.id])
  cbio_sg_id = length(aws_security_group.cbio_external_security_group) > 0 ? [aws_security_group.cbio_external_security_group[0].id] : []
}

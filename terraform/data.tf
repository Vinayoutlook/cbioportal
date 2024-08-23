data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data aws_ssm_parameter "session_manager_policy_arn" {
  name = "/${var.account}/security/session-manager/policy_arn"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.account}/platform/network/vpc_id"
}

data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/${var.account}/platform/network/private_subnet_ids"
}

data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${var.account}/platform/network/public_subnet_ids"
}

data "aws_ssm_parameter" "vpn_sg" {
  name = "/${var.account}/platform/network/vpn_sg"
}

data "aws_ssm_parameter" "vpn_external_cidrs" {
  name = "/${var.account}/platform/network/vpn_external_cidrs"
}

data "aws_ssm_parameter" "s3_logging_id" {
  name = "/${var.account}/security/account/alb_logging_id"
}

data "aws_ssm_parameter" "certificate_arn" {
  name = "/${var.env}/platform/domain/ecbio_certificate_arn"
}

data "aws_ssm_parameter" "certificate_keycloak_arn" {
  name = "/${var.env}/platform/domain/keycloak_certificate_arn"
}

data "aws_ssm_parameter" "data_zone_id" {
  name = "/${var.account}/platform/domain/zone_id"
}

data "aws_ecr_repository" "ecbio-repo" {
  name = "${var.account}-dp-tools-repositories-cbioportal"
}

data "aws_security_group" "compute_environment" {
  name = "${var.account}-${local.DataProduct}-batch-sg"
}

data "template_file" session_service_definition {
  template = file("${path.module}/template/session-service-definition.json")

  vars = {
    name                  = local.ecs_session_prefix
    image                 = local.session.container_image
    DOC_DB_USER           = data.aws_secretsmanager_secret_version.docdb_username.arn
    DOC_DB_PASSWORD       = data.aws_secretsmanager_secret_version.docdb_password.arn
    SERVER_PORT           = local.session.container_port
    JAVA_OPTS             = "-Dspring.data.mongodb.uri=mongodb://$${DOC_DB_USER}:$${DOC_DB_PASSWORD}@${module.document_db_cluster.instance_endpoint[0]}:${local.database.docdb_port}/session-service?retryWrites=false -Dlogging.level.root=DEBUG"
    containerPort         = 5000
    awslogs-group         = aws_cloudwatch_log_group.logs.name
    awslogs-stream-prefix = local.ecs_session_prefix
    awslogs-region        = var.aws_region
    INSTALL_BUNDLE        = data.aws_secretsmanager_secret_version.install_bundle.arn
    CONTAINER_NAME          = local.ecs_session_prefix
    WS_ADDRESS              = "wss://us-east1.cloud.twistlock.com:443"
    DEFENDER_TYPE           = "fargate"
  }
}

data "template_file" keycloak_task_definition {
  template = file("${path.module}/template/keycloak-task-definition.json")

  vars = {
    name                    = local.ecs_keycloak_prefix
    image                   = local.keycloak.container_image
    KC_DB_USERNAME          = data.aws_secretsmanager_secret_version.kcrds_username.arn
    KC_DB_PASSWORD          = data.aws_secretsmanager_secret_version.kcrds_password.arn
    #URL --> https://<env>.keycloak.data.guardanthealth.com"
    KC_HOSTNAME_URL         = var.account == "dpep" || var.account == "dpenp" ? "https://${var.env}.${local.keycloak.component}.enp${local.route53_domain_name}" : "https://${var.env}.${local.keycloak.component}.np${local.route53_domain_name}"
    KEYCLOAK_ADMIN          = data.aws_secretsmanager_secret_version.kcadmin_username.arn
    KEYCLOAK_ADMIN_PASSWORD = data.aws_secretsmanager_secret_version.kcadmin_pass.arn
    KC_DB                   = local.rds.rds_type
    KC_PROXY                = "edge"
    KC_DB_URL               = "jdbc:${local.rds.rds_type}://${module.aws_rds_cluster1.endpoint}:${local.database.rds_port}/${local.rds.kcrds_dbname}?useSSL=false"
    containerPort           = 8080
    awslogs-group           = aws_cloudwatch_log_group.logs.name
    awslogs-stream-prefix   = local.ecs_session_prefix
    awslogs-region          = var.aws_region
    INSTALL_BUNDLE          = data.aws_secretsmanager_secret_version.install_bundle.arn
    CONTAINER_NAME          = local.ecs_keycloak_prefix
    WS_ADDRESS              = "wss://us-east1.cloud.twistlock.com:443"
    DEFENDER_TYPE           = "fargate"
  }
}

data "template_file" cbioportal_task_definition {
  template = file("${path.module}/template/cbioportal-task-definition.json")
  for_each                = toset(local.client_list)

  vars = {
    name                    = "${each.key}-${local.ecs_cbio_prefix}"
    image                   = "${data.aws_ecr_repository.ecbio-repo.repository_url}:latest"
    METADATA_ENTITY_ID      = "${each.key}"
    DB_USER                 = data.aws_secretsmanager_secret_version.cbiords_username.arn
    DB_PASSWORD             = data.aws_secretsmanager_secret_version.cbiords_password.arn
    DB_CONNECTION_STRING    = "jdbc:mysql://${module.aws_rds_cluster.endpoint}:${local.database.rds_port}/${local.rds.cbiords_dbname}?useSSL=false"
    DB_TOMCAT_RESOURCE_NAME = "jdbc/cbioportal"
    CACHE_TYPE              = local.redis.cache_type
    REDIS_PASSWORD          = data.aws_secretsmanager_secret_version.redis_password.arn
    CACHE_ENDPOINT_API_KEY  = local.redis.cache_endpoint_key
    SAML_KEYSTORE_PASSWORD  = data.aws_secretsmanager_secret_version.saml_keystore.arn
    # URL --> <env>.nexus.npdata.guardanthealth.com
    BASE_URL                = "https://${var.env}.nexus.np${local.route53_domain_name}/${each.key}" # TODO testing change after proper URL is finalized
    CONTEXT_PATH            = "/${each.key}"
    ENTITY_BASE_URL         = "https://${var.env}.nexus.np${local.route53_domain_name}/${each.key}" # TODO testing change after proper URL is finalized
    ENTITY_ID               = "https://${var.env}.${local.keycloak.component}.np${local.route53_domain_name}/realms/cbio"
    DB_CONNECTION           = "jdbc:${local.rds.rds_type}://${module.aws_rds_cluster.endpoint}"
    REDIS_LEADER_ADDRESS    = "rediss://${module.elastic.primary_endpoint}:${local.database.redis_port}"
    REDIS_FOLLOWER_ADDRESS  = "rediss://${module.elastic.follower_endpoint}:${local.database.redis_port}"
    SESSION_SERVICE_URL     = "http://session.${aws_service_discovery_private_dns_namespace.ns.name}:${local.session.container_port}/api/sessions/myportal/"
    containerPort           = 8080
    awslogs-group           = aws_cloudwatch_log_group.logs.name
    awslogs-stream-prefix   = local.ecs_session_prefix
    awslogs-region          = var.aws_region
    INSTALL_BUNDLE          = data.aws_secretsmanager_secret_version.install_bundle.arn
    IDP_METADATA            = data.aws_secretsmanager_secret_version.idp_metadata_xml.arn
    CONTAINER_NAME          = local.ecs_cbio_prefix
    WS_ADDRESS              = "wss://us-east1.cloud.twistlock.com:443"
    DEFENDER_TYPE           = "fargate"
  }
}

data "template_file" cbioportal_task_definition_ext {
  template = file("${path.module}/template/cbioportal-task-definition_ext.json")
  for_each                = toset(local.client_list)

  vars = {
    name                    = "${each.key}-${local.ecs_cbio_prefix}"
    image                   = "${data.aws_ecr_repository.ecbio-repo.repository_url}:latest"
    METADATA_ENTITY_ID      = "${each.key}"
    DB_USER                 = data.aws_secretsmanager_secret_version.cbiords_username.arn
    DB_PASSWORD             = data.aws_secretsmanager_secret_version.cbiords_password.arn
    PORTAL_DB_NAME          = local.rds.cbiords_dbname
    CACHE_TYPE              = local.redis.cache_type
    REDIS_PASSWORD          = data.aws_secretsmanager_secret_version.redis_password.arn
    CACHE_ENDPOINT_API_KEY  = local.redis.cache_endpoint_key
    SAML_KEYSTORE_PASSWORD  = data.aws_secretsmanager_secret_version.saml_keystore.arn
    # URL --> <env>.nexus.enpdata.guardanthealth.com
    BASE_URL                = "https://${var.env}.nexus.enp${local.route53_domain_name}/${each.key}" # TODO testing change after proper URL is finalized
    CONTEXT_PATH            = "/${each.key}"
    ENTITY_BASE_URL         = "https://${var.env}.nexus.enp${local.route53_domain_name}/${each.key}" # TODO testing change after proper URL is finalized
    ENTITY_ID               = "https://${var.env}.${local.keycloak.component}.enp${local.route53_domain_name}/realms/cbio"
    DB_CONNECTION           = "jdbc:${local.rds.rds_type}://${module.aws_rds_cluster.endpoint}"
    REDIS_LEADER_ADDRESS    = "rediss://${module.elastic.primary_endpoint}:${local.database.redis_port}"
    REDIS_FOLLOWER_ADDRESS  = "rediss://${module.elastic.follower_endpoint}:${local.database.redis_port}"
    #SESSION_SERVICE_URL     = "http://session.${aws_service_discovery_private_dns_namespace.ns.name}:${local.session.container_port}/api/sessions/${each.key}/" TODO
    SESSION_SERVICE_URL     = "http://session.${aws_service_discovery_private_dns_namespace.ns.name}:${local.session.container_port}/api/sessions/myportal/"
    DB_HOST                 = module.aws_rds_cluster.endpoint
    containerPort           = 8080
    awslogs-group           = aws_cloudwatch_log_group.logs.name
    awslogs-stream-prefix   = local.ecs_session_prefix
    awslogs-region          = var.aws_region
    INSTALL_BUNDLE          = data.aws_secretsmanager_secret_version.install_bundle.arn
    IDP_METADATA            = data.aws_secretsmanager_secret_version.idp_metadata_xml.arn
    CONTAINER_NAME          = local.ecs_cbio_prefix
    WS_ADDRESS              = "wss://us-east1.cloud.twistlock.com:443"
    DEFENDER_TYPE           = "fargate"
  }
}

data "aws_nat_gateway" "nat_gw" {
  for_each = toset(nonsensitive(split(",", data.aws_ssm_parameter.public_subnet_ids.value)))
  subnet_id = each.value
}

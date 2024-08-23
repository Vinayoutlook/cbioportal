data "aws_secretsmanager_secret" "cbiords_user" {
  name = "/${local.prefix_path}/cbiords_user"
  #recovery_window_in_days = var.recovery_window_in_days
}

data "aws_secretsmanager_secret_version" "cbiords_username" {
  secret_id = data.aws_secretsmanager_secret.cbiords_user.id
}

data "aws_secretsmanager_secret" "cbiords_pass" {
  name = "/${local.prefix_path}/cbiords_password"
  #recovery_window_in_days = var.recovery_window_in_days
}

data "aws_secretsmanager_secret_version" "cbiords_password" {
  secret_id = data.aws_secretsmanager_secret.cbiords_pass.id
}

# data "aws_secretsmanager_secret" "cbiords_dbname" {
#   name = "/${local.prefix_account_path}/cbiords_dbname"
#   #recovery_window_in_days = var.recovery_window_in_days
# }
#
# data "aws_secretsmanager_secret_version" "cbiords_databasename" {
#   secret_id = data.aws_secretsmanager_secret.cbiords_dbname.id
# }

data "aws_secretsmanager_secret" "kcrds_user" {
  name = "/${local.prefix_path}/kcrds_user"
  #recovery_window_in_days = var.recovery_window_in_days
}

data "aws_secretsmanager_secret_version" "kcrds_username" {
  secret_id = data.aws_secretsmanager_secret.kcrds_user.id
}

data "aws_secretsmanager_secret" "kcrds_pass" {
  name = "/${local.prefix_path}/kcrds_password"
  #recovery_window_in_days = var.recovery_window_in_days
}

data "aws_secretsmanager_secret_version" "kcrds_password" {
  secret_id = data.aws_secretsmanager_secret.kcrds_pass.id
}

# data "aws_secretsmanager_secret" "kcrds_dbname" {
#   name = "/${local.prefix_account_path}/kcrds_dbname"
#   #recovery_window_in_days = var.recovery_window_in_days
# }
#
# data "aws_secretsmanager_secret_version" "kcrds_databasename" {
#   secret_id = data.aws_secretsmanager_secret.kcrds_dbname.id
# }

data "aws_secretsmanager_secret" "docdb_user" {
  name = "/${local.prefix_path}/docdb_user"
  #recovery_window_in_days = var.recovery_window_in_days
}

data "aws_secretsmanager_secret_version" "docdb_username" {
  secret_id = data.aws_secretsmanager_secret.docdb_user.id
}

data "aws_secretsmanager_secret" "docdb_pass" {
  name = "/${local.prefix_path}/docdb_password"
  #recovery_window_in_days = var.recovery_window_in_days
}

data "aws_secretsmanager_secret_version" "docdb_password" {
  secret_id = data.aws_secretsmanager_secret.docdb_pass.id
}

data "aws_secretsmanager_secret" "kcadmin_user" {
  name = "/${local.prefix_path}/kcadmin_user"
  #recovery_window_in_days = var.recovery_window_in_days
}

data "aws_secretsmanager_secret_version" "kcadmin_username" {
  secret_id = data.aws_secretsmanager_secret.kcadmin_user.id
}

data "aws_secretsmanager_secret" "kcadmin_pwd" {
  name = "/${local.prefix_path}/kcadmin_pwd"
  #recovery_window_in_days = var.recovery_window_in_days
}

data "aws_secretsmanager_secret_version" "kcadmin_pass" {
  secret_id = data.aws_secretsmanager_secret.kcadmin_pwd.id
}

# resource "aws_secretsmanager_secret" "kc_url" {
#   name = "/${local.prefix_account_path}/kc_url"
#   recovery_window_in_days = var.recovery_window_in_days
# }
#
# data "aws_secretsmanager_secret_version" "kc_url" {
#   secret_id = aws_secretsmanager_secret.kc_url.id
# }

data "aws_secretsmanager_secret" "redis_pass" {
  name = "/${local.prefix_path}/redis_password"
  #recovery_window_in_days = var.recovery_window_in_days
}

data "aws_secretsmanager_secret_version" "redis_password" {
  secret_id = data.aws_secretsmanager_secret.redis_pass.id
}

# data "aws_secretsmanager_secret" "cache_endpoint" {
#   name = "/${local.prefix_account_path}/cache_endpoint_key"
#   #recovery_window_in_days = var.recovery_window_in_days
# }
#
# data "aws_secretsmanager_secret_version" "cache_endpointkey" {
#   secret_id = data.aws_secretsmanager_secret.cache_endpoint.id
# }

# data "aws_secretsmanager_secret" "cache_type" {
#   name = "/${local.prefix_account_path}/cache_type"
#   #recovery_window_in_days = var.recovery_window_in_days
# }
#
# data "aws_secretsmanager_secret_version" "cache_type" {
#   secret_id = data.aws_secretsmanager_secret.cache_type.id
# }

# data "aws_secretsmanager_secret" "db_driver" {
#   name = "/${local.prefix_account_path}/db_driver"
#   #recovery_window_in_days = var.recovery_window_in_days
# }
#
# data "aws_secretsmanager_secret_version" "db_driver" {
#   secret_id = data.aws_secretsmanager_secret.db_driver.id
# }

data "aws_secretsmanager_secret" "saml_Keystore" {
  name = "/${local.prefix_path}/SAML_keystore"
  #recovery_window_in_days = var.recovery_window_in_days
}

data "aws_secretsmanager_secret_version" "saml_keystore" {
  secret_id = data.aws_secretsmanager_secret.saml_Keystore.id
}

# resource "aws_secretsmanager_secret" "base_url" {
#   name = "/${local.prefix_account_path}/base_url"
#   recovery_window_in_days = var.recovery_window_in_days
# }
#
# data "aws_secretsmanager_secret_version" "base_url" {
#   secret_id = aws_secretsmanager_secret.base_url.id
# }

data "aws_secretsmanager_secret" "prisma_install_bundle" {
  name = "/${var.account}/security/prisma-cloud/install_bundle"
}

data "aws_secretsmanager_secret_version" "install_bundle" {
  secret_id = data.aws_secretsmanager_secret.prisma_install_bundle.id
}

data "aws_secretsmanager_secret" "idp_metadata_xml" {
  name = "/${local.prefix_path}/idp_metadata"
}

data "aws_secretsmanager_secret_version" "idp_metadata_xml" {
  secret_id = data.aws_secretsmanager_secret.idp_metadata_xml.id
}

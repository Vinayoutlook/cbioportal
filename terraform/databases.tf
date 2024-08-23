#creating document DB using glue template.We have disabled tls encryption
module "document_db_cluster" {
  source                          = "./.dependencies/terraform-aws-gh-dp-glue/documentdb"
  aws_region                      = var.aws_region
  env                             = var.env
  account                         = var.account
  data_product                    = local.DataProduct
  component                       = local.Component
  name                            = "docdbcbio"
  db_cluster_parameter_group_name = "${var.account}-platform-ecbio-docdb-parameter-group"
  master_username                 = data.aws_secretsmanager_secret_version.docdb_username.secret_string
  master_password                 = data.aws_secretsmanager_secret_version.docdb_password.secret_string
  vpc_security_group_ids = [aws_security_group.cbio_ecs_security_group.id]
  storage_encrypted               = true
  tls_option = "disabled" #TODO : tls needs to be enabled
  kms_key_id                      = aws_kms_key.cbio_kms_key.arn
  deletion_protection = false  #TODO : remove before release
  compliance = merge(local.compliance, {
    PHI_PII_Information = "No"
  })
}
#   monitoring = {
#     ### Service Availability Monitoring
#     database_connections = {
#       period                          = 300
#       less_than_threshold = 1
#     }
#     ### Service Quality Monitoring
#     avg_cpu_utilization = {
#       period                          = 600
#       greater_than_or_equal_to_threshold = 70
#       less_than_threshold             = -1
#     }
#     avg_freeable_memory = {
#       period                          = 600
#       less_than_threshold             = 256000000 # = 256 MB
#     }
#     avg_read_latency = {
#       period                          = 600
#       greater_than_threshold          = 50
#     }
#     avg_write_latency = {
#       period                          = 600
#       greater_than_threshold          = 50
#     }
#     ### Additional Monitoring - not part of ecBio
#     avg_buffer_cache_hit_ratio = {
#       period                          = 600
#       less_than_threshold             = -1
#     }
#     sum_database_cursors = {
#       period                          = 600
#       greater_than_threshold          = -1
#     }
#     avg_disk_queue_depth = {
#       period                          = 600
#       greater_than_threshold          = -1
#     }
#     avg_index_buffer_cache_hit_ratio = {
#       period                          = 600
#       less_than_threshold             = -1
#     }
#     avg_swap_usage = {
#       period                          = 600
#       greater_than_threshold          = -1
#     }
#     avg_cpu_volume_write_iops = {
#       period                          = 600
#       greater_than_threshold          = -1
#     }
#     avg_cpu_volume_read_iops = {
#       period                          = 600
#       greater_than_threshold          = -1
#     }
#   }
# }

# Using glue template creating Amazon aurora RDS for CBIO.
module "aws_rds_cluster" {
  source                      = "./.dependencies/terraform-aws-gh-dp-glue/aurorards"
  storage_encrypted           = true
  aws_region                  = var.aws_region
  env                         = var.env
  account                     = var.account
  data_product                = local.DataProduct
  component                   = local.Component
  name = "${local.Component}-rds"  # TODO glue adds env and DataProduct --> <env>-<DataProduct>-<Component>-rds
  engine                      = local.rds.engine
  engine_version              = local.rds.engine_version
  apply_immediately           = true
  allow_major_version_upgrade = true
  db_parameter_group_name     = "${var.account}-${local.DataProduct}-${local.Component}-rds-parameter-group"
  database_name               = local.rds.cbiords_dbname
  master_username             = data.aws_secretsmanager_secret_version.cbiords_username.secret_string
  master_password             = data.aws_secretsmanager_secret_version.cbiords_password.secret_string
  vpc_security_group_ids = [aws_security_group.cbio_ecs_security_group.id]
  kms_key_id                  = aws_kms_key.cbio_kms_key.arn
  identifier                  = "${local.prefix}-cbiodb"
  instance_class              = local.rds.instance_class
}
#  monitoring = {
#    ### Service Availability Monitoring
#    database_connections = {
#      period                          = 300
#      less_than_threshold = 1
#    }
#    ### Service Quality Monitoring
#    avg_cpu_utilization = {
#      period                          = 600
#      greater_than_or_equal_to_threshold = 70
#      less_than_threshold             = -1
#    }
#    avg_freeable_memory = {
#      period                          = 600
#      less_than_threshold             = 256000000 # = 256 MB
#    }
#    avg_read_latency = {
#      period                          = 600
#      greater_than_threshold          = 50
#    }
#    avg_write_latency = {
#      period                          = 600
#      greater_than_threshold          = 50
#    }
#  }
# }

# Using glue template creating Amazon aurora RDS for Keycloak.
module "aws_rds_cluster1" {
  source                  = "./.dependencies/terraform-aws-gh-dp-glue/aurorards"
  storage_encrypted       = true
  aws_region              = var.aws_region
  env                     = var.env
  account                 = var.account
  data_product            = local.DataProduct
  component               = local.Component
  name = "${local.Component}-kcrds"  # # TODO glue adds env and DataProduct --> <env>-<DataProduct>-<Component>-kcrds
  engine                  = local.rds.engine
  engine_version          = local.keycloak.engine_version
  apply_immediately       = true
  database_name           = local.rds.kcrds_dbname
  master_username         = data.aws_secretsmanager_secret_version.kcrds_username.secret_string
  master_password         = data.aws_secretsmanager_secret_version.kcrds_password.secret_string
  db_parameter_group_name = "${var.account}-${local.DataProduct}-${local.Component}-rds-keycloak-parameter-group"
  vpc_security_group_ids = [aws_security_group.cbio_ecs_security_group.id]
  kms_key_id              = aws_kms_key.cbio_kms_key.arn
  identifier              = "${local.prefix}-kcrds"
  instance_class          = local.keycloak.instance_class
}
#  monitoring = {
#    ### Service Availability Monitoring
#    database_connections = {
#      period                          = 300
#      less_than_threshold = 1
#    }
#    ### Service Quality Monitoring
#    avg_cpu_utilization = {
#      period                          = 600
#      greater_than_or_equal_to_threshold = 70
#      less_than_threshold             = -1
#    }
#    avg_freeable_memory = {
#      period                          = 600
#      less_than_threshold             = 256000000 # = 256 MB
#    }
#    avg_read_latency = {
#      period                          = 600
#      greater_than_threshold          = 50
#    }
#    avg_write_latency = {
#      period                          = 600
#      greater_than_threshold          = 50
#    }
#  }
# }

# Creating in-cache memory using glue template
module "elastic" {
  source                     = "./.dependencies/terraform-aws-gh-dp-glue/elasticache"
  aws_region                 = var.aws_region
  account                    = var.account
  env                        = var.env
  component                  = local.Component
  name                       = "elastic"
  data_product               = local.DataProduct
  redis_node_type            = local.redis.instance_type
  redis_clusters             = local.redis.clusters_count
  auth_token                 = data.aws_secretsmanager_secret_version.redis_password.secret_string
  transit_encryption_enabled = local.redis.encription_enabled
  security_group_ids = [aws_security_group.cbio_ecs_security_group.id]

  monitoring = {                    # TODO Remove this mandatory component from glue
    curr_connections = {
      period                          = 600
      less_than_threshold             = 1
    }
    avg_cpu_utilization = {
      period                          = 600
      greater_than_or_equal_to_threshold = 70
    }
    swap_usage = {
      period                          = 600
      greater_than_threshold          = 104857600 # 1024*1024*100 Bytes # 100MB
    }
    evictions = {
      period                          = 600
      greater_than_threshold          = 0
    }
  }
}
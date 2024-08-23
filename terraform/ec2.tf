####################################################
# TODO Temporary code for EC2 instance used for load testing

locals {                  # "c7a.24xlarge" or "c7a.medium"
  instance_type1          = "c7a.medium"
  instance_type2          = "c7a.medium"
  instance_type3          = "c7a.medium"
  instance_type4          = "c7a.medium"
  instance_type5          = "c7a.medium"
  create_resources         = var.account == "dpnp" && var.env == "dev" ? 1 : 0
}

resource "aws_iam_role_policy_attachment" load_testing_ssm_managed_instance_policy {
  count  = local.create_resources
  role       = module.service-role.gh_dp_data_asset_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_role_policy_attachment" load_testing_ssm_managed_instance_policy2 {
  count  = local.create_resources
  role       = module.service-role.gh_dp_data_asset_role_name
  policy_arn = data.aws_ssm_parameter.session_manager_policy_arn.value
}

resource "aws_iam_instance_profile" load_testing_instance_profile {
  count  = local.create_resources
  name = "${local.prefix}-profile"
  role = module.service-role.gh_dp_data_asset_role_name
  tags = merge(
    local.tags,
    {
      Name = "${local.prefix}-profile"
    })
}

resource "aws_security_group" load_testing_ec2_security_group {
  count  = local.create_resources
  name   = "${local.prefix}-jmeter-sg"
  vpc_id = nonsensitive(data.aws_ssm_parameter.vpc_id.value)

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    description = "Internet connection"
  }

  tags = merge(local.tags, {
    Name = "${local.prefix}-sg"
  })
}

resource "aws_instance" load_testing_ec2 {
  count  = local.create_resources
  ami                    = "ami-0c7843ce70e666e51"
  instance_type          = local.instance_type1
  user_data              = data.template_file.user_data[count.index].rendered
  subnet_id              = nonsensitive(split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0])
  vpc_security_group_ids = [aws_security_group.load_testing_ec2_security_group[count.index].id]
  iam_instance_profile   = aws_iam_instance_profile.load_testing_instance_profile[count.index].id
  root_block_device {
    volume_type = "gp3"
    volume_size = "500"
  }

  metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
  }
  tags = merge(local.tags, {
    Name                     = "${var.env}-${local.DataProduct}-${local.Component}-load-testing-ec2"
    dp-software-nl2sql-admin = "true"
  })
}

resource "aws_instance" load_testing_ec2_2 {
  count  = local.create_resources
  ami                    = "ami-0c7843ce70e666e51"
  instance_type          = local.instance_type2
  user_data              = data.template_file.user_data[count.index].rendered
  subnet_id              = nonsensitive(split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0])
  vpc_security_group_ids = [aws_security_group.load_testing_ec2_security_group[count.index].id]
  iam_instance_profile   = aws_iam_instance_profile.load_testing_instance_profile[count.index].id
  root_block_device {
    volume_type = "gp3"
    volume_size = "500"
  }

  metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
  }
  tags = merge(local.tags, {
    Name                     = "${var.env}-${local.DataProduct}-${local.Component}-load-testing-ec2_2"
    dp-software-nl2sql-admin = "true"
  })
}

resource "aws_instance" load_testing_ec2_3 {
  count  = local.create_resources
  ami                    = "ami-0c7843ce70e666e51"
  instance_type          = local.instance_type3
  user_data              = data.template_file.user_data[count.index].rendered
  subnet_id              = nonsensitive(split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0])
  vpc_security_group_ids = [aws_security_group.load_testing_ec2_security_group[count.index].id]
  iam_instance_profile   = aws_iam_instance_profile.load_testing_instance_profile[count.index].id
  root_block_device {
    volume_type = "gp3"
    volume_size = "500"
  }

  metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
  }
  tags = merge(local.tags, {
    Name                     = "${var.env}-${local.DataProduct}-${local.Component}-load-testing-ec2_3"
    dp-software-nl2sql-admin = "true"
  })
}

resource "aws_instance" load_testing_ec2_4 {
  count  = local.create_resources
  ami                    = "ami-0c7843ce70e666e51"
  instance_type          = local.instance_type4
  user_data              = data.template_file.user_data[count.index].rendered
  subnet_id              = nonsensitive(split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0])
  vpc_security_group_ids = [aws_security_group.load_testing_ec2_security_group[count.index].id]
  iam_instance_profile   = aws_iam_instance_profile.load_testing_instance_profile[count.index].id
  root_block_device {
    volume_type = "gp3"
    volume_size = "500"
  }

  metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
  }
  tags = merge(local.tags, {
    Name                     = "${var.env}-${local.DataProduct}-${local.Component}-load-testing-ec2_4"
    dp-software-nl2sql-admin = "true"
  })
}

resource "aws_instance" load_testing_ec2_5 {
  count  = local.create_resources
  ami                    = "ami-0c7843ce70e666e51"
  instance_type          = local.instance_type5
  user_data              = data.template_file.user_data[count.index].rendered
  subnet_id              = nonsensitive(split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0])
  vpc_security_group_ids = [aws_security_group.load_testing_ec2_security_group[count.index].id]
  iam_instance_profile   = aws_iam_instance_profile.load_testing_instance_profile[count.index].id
  root_block_device {
    volume_type = "gp3"
    volume_size = "500"
  }

  metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
  }
  tags = merge(local.tags, {
    Name                     = "${var.env}-${local.DataProduct}-${local.Component}-load-testing-ec2_5"
    dp-software-nl2sql-admin = "true"
  })
}

resource "aws_iam_policy" "start_session_policy" {
  count  = local.create_resources
  name        = "StartSessionPolicy"
  description = "Policy to allow starting a session with EC2 instance and running commands"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ssm:StartSession",
          "ssm:DescribeSessions",
          "ssm:TerminateSession",
          "ssm:SendCommand",
          "ssm:ListCommandInvocations",
          "ssm:GetConnectionStatus",
          "ssm:DescribeInstanceProperties",
          "ssm:ResumeSession",
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes"
        ],
        Resource = [
          "arn:aws:ec2:us-west-2:617336469044:instance/i-0e774c089705ef59d", #EC2
          "arn:aws:ec2:us-west-2:617336469044:instance/i-09ebac7868ff422ed", #EC2_2
          "arn:aws:ec2:us-west-2:617336469044:instance/i-09024a3893d15fca8", #EC2_3
          "arn:aws:ec2:us-west-2:617336469044:instance/i-08973aa31272446a6", #EC2_4
          "arn:aws:ec2:us-west-2:617336469044:instance/i-0e6fdc9ef3f2d0673"  #EC2_5
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "data_engineer_start_session_policy" {
  count  = local.create_resources
  role       = "user-role-dp-data-engineers"
  policy_arn = aws_iam_policy.start_session_policy[count.index].arn
}

# Define the IAM policy to access the S3 bucket
resource "aws_iam_policy" "s3_access_policy" {
  count  = local.create_resources
  name        = "S3AccessPolicy"
  description = "Policy to allow access to the S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::gh-dp-data-dev-reference-ingestion-job/data/eCbio_load_testing",
          "arn:aws:s3:::gh-dp-data-dev-reference-ingestion-job/data/eCbio_load_testing/*"
        ]
      }
    ]
  })
}

# Attach the policy to the IAM role associated with the EC2 instance
resource "aws_iam_role_policy_attachment" "s3_access_policy_attachment" {
  count  = local.create_resources
  role       = module.service-role.gh_dp_data_asset_role_name
  policy_arn = aws_iam_policy.s3_access_policy[count.index].arn
}

data "aws_secretsmanager_secret" "defender_user_name" {
  count  = local.create_resources
  name = "/${var.account}/security/jenkins/prisma_access_key"
}

data "aws_secretsmanager_secret_version" "defender_user_name_version" {
  count  = local.create_resources
  secret_id = data.aws_secretsmanager_secret.defender_user_name[count.index].id
}

data "aws_secretsmanager_secret" "defender_user_password" {
  count  = local.create_resources
  name = "/${var.account}/security/jenkins/prisma_secret"
}

data "aws_secretsmanager_secret_version" "defender_user_password_version" {
  count  = local.create_resources
  secret_id = data.aws_secretsmanager_secret.defender_user_password[count.index].id
}

data "template_file" "user_data" {
  count  = local.create_resources
  template = "${file("pre_install.sh.tpl")}"
  vars = {
    aws_region             = var.aws_region
    account                = var.account
    env                    = var.env
    defender_user_name     = data.aws_secretsmanager_secret_version.defender_user_name_version[count.index].secret_string
    defender_user_password = data.aws_secretsmanager_secret_version.defender_user_password_version[count.index].secret_string
  }
}
####################################################
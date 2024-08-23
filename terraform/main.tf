provider aws {
  region = var.aws_region
}

provider github {
}

terraform {
  backend "s3" {
  }
}

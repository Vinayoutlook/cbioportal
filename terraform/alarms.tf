//Document ref : https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Synthetics_Canaries_metrics.html
// This file contains the cloud watch alerts for Canary.

##################################################################################################################
# Canary Alarms
##################################################################################################################
# Alarms can be designed based on the metrics published by the canary.
# Metrics Published by a canary are listed here :
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Synthetics_Canaries_metrics.html

module "canarySuccessPercent" {

  # SuccessPercent
  # The percentage of the runs of this canary that succeed and find no failures.
  # Valid Dimensions: CanaryName
  # Valid Statistic: Average
  # Units: Percent

  source = "./.dependencies/terraform-aws-gh-dp-glue/cloudwatch/alarm"

  # Name and description
  alarm_name = "${module.cbio-sanity.canary_name}-SuccessPercent"
  alarm_description = "Raise alarm if the success percent drops below 95%"

  # Alarm if average success percent is less than 95 percent for 3 datapoints within 10 minutes.
  # Missing data is a breach.
  statistic = "Average"
  metric_name = "SuccessPercent"
  comparison_operator = "LessThanThreshold"
  threshold = 95
  datapoints_to_alarm = 3
  evaluation_periods = 3
  period = 600
  unit = "Percent"
  treat_missing_data = "breaching"

  # Standard parameters
  data_product          = local.DataProduct
  component             = local.Component
  account               = var.account
  env                   = var.env

  # Name space and Dimensions
  namespace = "AWS/Canary"
  dimensions = {
    CanaryName = module.cbio-sanity.canary_name
  }

}

module "canaryDuration" {

  # The duration in milliseconds of the canary run.
  # Valid Dimensions: CanaryName
  # Valid Statistic: Average
  # Units: Milliseconds
  # Duration > 30000 for 3 datapoints within 10 minutes

  source = "./.dependencies/terraform-aws-gh-dp-glue/cloudwatch/alarm"

  # Name and description
  alarm_name            = "${module.cbio-sanity.canary_name}-Duration"
  alarm_description     = "Raise alarm if duration breach is observed."

  # Alarm if average duration is greater than 30000 milliseconds
  # for 3 datapoints within 10 minutes.
  statistic             = "Average"
  metric_name           = "Duration"
  comparison_operator   = "GreaterThanThreshold"
  threshold             = 30000 # milliseconds
  datapoints_to_alarm   = 3
  evaluation_periods    = 3
  period                = 600 # seconds
  unit                  = "Milliseconds"
  treat_missing_data    = "breaching"

  # Standard parameters
  data_product          = local.DataProduct
  component             = local.Component
  account               = var.account
  env                   = var.env

  # Name space and Dimensions
  namespace = "AWS/Canary"
  dimensions = {
    BucketName = module.cbio-sanity.canary_name
  }
}

provider "aws" {
  region = "eu-west-1"
}

# Create the SNS topic
resource "aws_sns_topic" "SmartlistG2_CloudWatch_Alarms_Topic" {
  name = "SmartlistG2_CloudWatch_Alarms_Topic"
}

# Create the email subscription
resource "aws_sns_topic_subscription" "email-subscription" {
  topic_arn = aws_sns_topic.SmartlistG2_CloudWatch_Alarms_Topic.arn
  protocol  = "email"
  endpoint  = "user@solvyng.io"
}

#Create alarm for consumed RCU 
resource "aws_cloudwatch_metric_alarm" "consumed_rcu" {
  alarm_name          = "SmartlistG2_CloudWatch_Alarms_RCUs"
  alarm_description   = "This alarm will trigger when the threshold >80% for the period of 5 min."
  metric_name         = "ConsumedReadCapacityUnits"
  namespace           = "AWS/DynamoDB"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = ["arn:aws:sns:eu-west-1:456561060854:SmartlistG2_CloudWatch_Alarms_Topic"]
}

#Create alarm for consumed WCU 
resource "aws_cloudwatch_metric_alarm" "consumed_wcu" {
  alarm_name          = "SmartlistG2_CloudWatch_Alarms_WCUs"
  alarm_description   = "This alarm will trigger when the threshold >80% for the period of 5 min."
  metric_name         = "ConsumedWriteCapacityUnits"
  namespace           = "AWS/DynamoDB"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = ["arn:aws:sns:eu-west-1:456561060854:SmartlistG2_CloudWatch_Alarms_Topic"]
}

#Create alarm for sign_up_success
resource "aws_cloudwatch_metric_alarm" "sign_up_success_alarm" {
  alarm_name          = "SmartlistG2_CloudWatch_Alarms_SignupSuccess"
  alarm_description   = "This alarm will trigger when the threshold >5 for the period of 5 min."
  metric_name         = "SignInSuccess"
  namespace           = "AWS/Cognito"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 5
  comparison_operator = "LessThanThreshold"
  alarm_actions       = ["arn:aws:sns:eu-west-1:456561060854:SmartlistG2_CloudWatch_Alarms_Topic"]
}

#Create alarm for sign_in_success
resource "aws_cloudwatch_metric_alarm" "sign_in_success_alarm" {
  alarm_name          = "SmartlistG2_CloudWatch_Alarms_SigninSuccess"
  alarm_description   = "This alarm will trigger when the threshold >5 for the period of 5 min."
  metric_name         = "SignUpSuccess"
  namespace           = "AWS/Cognito"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 5
  comparison_operator = "LessThanThreshold"
  alarm_actions       = ["arn:aws:sns:eu-west-1:456561060854:SmartlistG2_CloudWatch_Alarms_Topic"]
}

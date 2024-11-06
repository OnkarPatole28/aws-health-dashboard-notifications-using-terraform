# main.tf
provider "aws" {
  region                 = "us-east-1"  # Change to your preferred region
  access_key            = var.aws_access_key_id
  secret_key            = var.aws_secret_access_key
}
# Step 1: Create an SNS Topic
resource "aws_sns_topic" "aws_health_dashboard_scheduled_changes" {
  name = "aws-health-dashboard-scheduled-changes"
}

# Step 2: Create an SNS Subscription
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.aws_health_dashboard_scheduled_changes.arn
  protocol  = "email"
  endpoint  = var.sns_email  # Referencing email from variables
}
# Step 3: Create an EventBridge Rule for AWS Health events
resource "aws_cloudwatch_event_rule" "eventbridge_rule_for_scheduled_changes" {
  name                = "eventbridge-rule-for-scheduled-changes"
  description         = "This rule will be used to capture scheduled changes in the AWS Health Dashboard."
  event_pattern       = jsonencode({
    "source": ["aws.health"],
    "detail-type": ["AWS Health Event"],
    "detail": {
      "eventTypeCategory": ["scheduledChange"]
    }
  })
}

# Step 4: Create a target for the EventBridge Rule
resource "aws_cloudwatch_event_target" "sns_topic" {
  rule      = aws_cloudwatch_event_rule.eventbridge_rule_for_scheduled_changes.name
  target_id = "sendToSNS"
  arn       = aws_sns_topic.aws_health_dashboard_scheduled_changes.arn
}


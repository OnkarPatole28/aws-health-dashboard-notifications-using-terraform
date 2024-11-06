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
# Step 5: IAM Role for EventBridge to send messages to SNS
resource "aws_iam_role" "eventbridge_role" {
  name = "iam-role-for-eventbridge-to-sns"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "events.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })
}

# Step 6: Create a custom policy for EventBridge to publish messages to SNS
resource "aws_iam_policy" "eventbridge_sns_publish_policy" {
  name        = "eventbridge-sns-publish-policy"
  description = "Policy to allow EventBridge to send notifcation to SNS"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sns:Publish",
        Resource = aws_sns_topic.aws_health_dashboard_scheduled_changes.arn
      }
    ]
  })
}

# Step 7: Attach the custom policy to the IAM Role
resource "aws_iam_policy_attachment" "eventbridge_policy_attachment" {
  name       = "eventbridge-to-sns-policy-attachment"
  roles      = [aws_iam_role.eventbridge_role.name]
  policy_arn = aws_iam_policy.eventbridge_sns_publish_policy.arn
}



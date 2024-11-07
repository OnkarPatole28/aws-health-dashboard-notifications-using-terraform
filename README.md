# aws-health-dashboard-notifications-using-terraform

This is a Terraform project that uses AWS EventBridge, Simple Notification Service (SNS), and IAM roles to send notifications of scheduled changes from the AWS Health Dashboard via email. The project creates a topic in SNS and subscribes an email as an endpoint.

We are also creating an IAM role and a custom IAM policy to allow EventBridge to send event notifications to the SNS topic.

In addition, we are using a deploy.sh script that downloads the necessary plugins for the AWS provider, validates the Terraform code, applies the Terraform configurations, and checks if the apply command was successful.
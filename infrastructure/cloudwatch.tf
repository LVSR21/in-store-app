#################################
## Create CloudWatch Log Group ##
#################################

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/${lower(var.namespace)}/ecs/${var.environment}" # The name of the log group.
  retention_in_days = var.retention_in_days                             # The number of days to retain the log events in the log group before delete them. By default, logs never expire.

  tags = {
    Scenario = var.scenario
  }
}



#------------------------- EXPLANATION -------------------------#
# CloudWatch is a AWS's monitoring and observability service. It collects logs, metrics and events. It enables real-time monitoring of AWS resources and applications.
# CloudWatch can monitor resources, tracking performance, auditing compliance, troubleshooting issues and application logging.
# In my case I'm creating a log group to store logs from my ECS (Elastic Container Service) which will collect container logs, store them in an organised structure, apply retention policies and enable lof analysis and monitoring.
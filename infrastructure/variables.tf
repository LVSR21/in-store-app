##########################
## Deployment variables ##
##########################

variable "namespace" {
  description = "Namespace for resource names"
  default     = "jd"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the application/website"
  type        = string
  default     = "in-store-app.co.uk"
}

variable "scenario" {
  description = "Scenario name for tags"
  default     = "scenario-ecs-ec2"
  type        = string
}

variable "environment" {
  description = "Environment for deployment"
  default     = "prod"
  type        = string
}

###############################
## AWS credentials variables ##
###############################

variable "region" {
  description = "AWS region"
  default     = "eu-west-2"
  type        = string
}

#######################
## Network variables ##
#######################

variable "parent_zone_id" {
  description = "Zone ID of in-store-app.co.uk"
  type        = string
  default     = "Z0424262FAPMZ7KJ2ASZ"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC network"
  default     = "10.0.0.0/16"
  type        = string
}

variable "az_count" {
  description = "Describes how many availability zones are used"
  default     = 2
  type        = number
}


#############################
## EC2 Computing variables ##
#############################

variable "instance_type" {
  description = "Instance type for EC2"
  default     = "t3.medium"
  type        = string
}

variable "instance_key_pair" {
  description = "Key pair for EC2 instances"
  type        = string
  default     = "in-store-app-key-pair"
}

###################
## ECS variables ##
###################

variable "image_version" {
  description = "Version tag for container images"
  type        = string
}

variable "ecs_task_desired_count" {
  description = "How many ECS tasks should run in parallel"
  type        = number
  default     = 2
}

variable "ecs_task_min_count" {
  description = "How many ECS tasks should minimally run in parallel"
  default     = 2
  type        = number
}

variable "ecs_task_max_count" {
  description = "How many ECS tasks should maximally run in parallel"
  default     = 10
  type        = number
}

variable "ecs_task_deployment_minimum_healthy_percent" {
  description = "How many percent of a service must be running to still execute a safe deployment"
  default     = 50
  type        = number
}

variable "ecs_task_deployment_maximum_percent" {
  description = "How many additional tasks are allowed to run (in percent) while a deployment is executed"
  default     = 100
  type        = number
}

variable "cpu_target_tracking_desired_value" {
  description = "Target tracking for CPU usage in %"
  default     = 70
  type        = number
}

variable "memory_target_tracking_desired_value" {
  description = "Target tracking for memory usage in %"
  default     = 80
  type        = number
}

variable "maximum_scaling_step_size" {
  description = "Maximum amount of EC2 instances that should be added on scale-out"
  default     = 5
  type        = number
}

variable "minimum_scaling_step_size" {
  description = "Minimum amount of EC2 instances that should be added on scale-out"
  default     = 1
  type        = number
}

variable "target_capacity" {
  description = "Amount of resources of container instances that should be used for task placement in %"
  default     = 100
  type        = number
}

variable "container_port" {
  description = "Port of the container"
  type        = number
  default     = 3000
}

variable "cpu_units" {
  description = "Amount of CPU units for a single ECS task"
  default     = 256
  type        = number
}

variable "memory" {
  description = "Amount of memory in MB for a single ECS task"
  default     = 2048
  type        = number
}

variable "mongodb_connection_string" {
  description = "MongoDB connection string"
  type        = string
}

##########################
## Cloudwatch variables ##
##########################

variable "retention_in_days" {
  description = "Retention period for Cloudwatch logs"
  default     = 7
  type        = number
}


#################################
## Autoscaling Group variables ##
#################################

variable "autoscaling_max_size" {
  description = "Max size of the autoscaling group"
  default     = 4
  type        = number
}

variable "autoscaling_min_size" {
  description = "Min size of the autoscaling group"
  default     = 2
  type        = number
}

variable "autoscaling_desired_capacity" {
  description = "Desired capacity of the autoscaling group"
  default     = 4
  type        = number
}

###################
## ALB variables ##
###################

variable "custom_origin_host_header" {
  description = "Custom header to ensure communication only through CloudFront"
  default     = "Demo123"
  type        = string
}

variable "healthcheck_endpoint" {
  description = "Endpoint for ALB healthcheck"
  type        = string
  default     = "/"
}

variable "healthcheck_matcher" {
  description = "HTTP status code matcher for healthcheck"
  type        = string
  default     = "200"
}
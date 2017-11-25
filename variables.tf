variable "task_definitions_name" {
  default = "task-definitions"
  description = "The name of task definitions."
}

variable "service_name" {
  description = "The name of the service."
}

variable "container_name" {
  default = "ecs-task-as1"
}

variable "create_alb" {
  default = false
}

variable "alb_arn" {
  default = "OVERWRITE VALUE AND CHANGE create_alb=true IF YOU WANT TO DEPLOY WITH ALB"
}

variable "ecs_profile_arn" {
  default = "OVERWRITE VALUE AND CHANGE create_alb=true IF YOU WANT TO DEPLOY WITH ALB"
}

variable "mongo_url" {}

variable "sha_tag" {}

variable "cluster_id" {}

variable "ecr_url" {}

variable "environment" {}

variable "version" {}

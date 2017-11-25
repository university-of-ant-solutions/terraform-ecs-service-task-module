## State storage
terraform {
  backend "s3" {}
}

data "template_file" "task_definitions" {
  template = "${file("${path.module}/templates/auth_service_task_definitions.json")}"

  vars {
    sha_tag           = "${var.sha_tag}"
    ecr_url           = "${var.ecr_url}"
    mongo_url         = "${var.mongo_url}"
    container_name    = "${local.container_name}"
  }
}

data "template_file" "task_definitions_alb" {
  template = "${file("${path.module}/templates/auth_service_task_definitions_alb.json")}"

  vars {
    sha_tag           = "${var.sha_tag}"
    ecr_url           = "${var.ecr_url}"
    mongo_url         = "${var.mongo_url}"
    container_name    = "${local.container_name}"
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family = "${local.task_definitions_name}" # Task Definition Name
  container_definitions = "${data.template_file.task_definitions.rendered}"
  network_mode = "bridge"
  # placement_constraints: []
  # volumes: []
  count = "${1 - var.create_alb}"
}

resource "aws_ecs_task_definition" "task_definition_alb" {
  family = "${local.task_definitions_name}" # Task Definition Name
  container_definitions = "${data.template_file.task_definitions_alb.rendered}"
  network_mode = "bridge"
  # placement_constraints: []
  # volumes: []
  count = "${var.create_alb}"
}

resource "aws_ecs_service" "service" {
  name = "${var.service_name}"
  cluster = "${var.cluster_id}"
  task_definition = "${aws_ecs_task_definition.task_definition.arn}"
  desired_count = 1

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  deployment_maximum_percent = 200 # allow to create 2 new task before remove old task
  # if new task is failed, all of old task is still run
  deployment_minimum_healthy_percent = 0

  count = "${1 - var.create_alb}"
}


resource "aws_ecs_service" "service-with-alb" {
  name = "${var.service_name}"
  cluster = "${var.cluster_id}"
  task_definition = "${aws_ecs_task_definition.task_definition_alb.arn}"
  iam_role = "${var.ecs_profile_arn}"
  desired_count = 1

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${var.alb_arn}"
    container_name = "${local.container_name}"
    container_port = 4000
  }

  deployment_maximum_percent = 200 # allow to create 2 new task before remove old task
  # if new task is failed, all of old task is still run
  deployment_minimum_healthy_percent = 0

  count = "${var.create_alb}"
}

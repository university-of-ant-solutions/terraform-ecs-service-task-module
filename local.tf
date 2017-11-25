locals {
  task_definitions_name       = "${var.task_definitions_name}-${var.environment}-${var.service_name}"
  container_name              = "${var.container_name}-${var.environment}-${var.service_name}"
}

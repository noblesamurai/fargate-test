# Create the log group we want to use for logging
resource "aws_cloudwatch_log_group" "group" {
  name = "/fargate-test"
  retention_in_days = 7
}

# Spielberg Container Definition
module "main_container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.23.0"

  container_name = "fargate-test"
  container_image = "214161443720.dkr.ecr.${var.region}.amazonaws.com/fargate-test:latest"
  container_cpu = null
  container_memory = null
  container_memory_reservation = var.task_memory / 2
  port_mappings = []
  log_configuration = {
    logDriver: "awslogs",
    options: {
      "awslogs-group": aws_cloudwatch_log_group.group.name,
      "awslogs-region": var.region,
      "awslogs-stream-prefix": "fargate-test"
    },
    secretOptions: null
  }
  # the following stops the task definition from being recreated every time...
  user = "0"
}

# Spielberg Task Definition
resource "aws_ecs_task_definition" "td" {
  family = "fargate-test-td"
  cpu = var.task_cpu
  memory = var.task_memory
  container_definitions = "[ ${module.main_container_definition.json_map} ]"
  task_role_arn = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}

# AWS Security Group
resource "aws_security_group" "ecs_tasks_sg" {
  name = "fargate-test-ecs-tasks-sg"
  description = "Allow egress only"
  vpc_id = aws_vpc.vpc.id
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    prefix_list_ids = [aws_vpc_endpoint.s3.prefix_list_id]
  }
  egress {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# AWS ECS Service
resource "aws_ecs_service" "service" {
  name = "fargate-test-service"
  platform_version = "1.4.0"
  cluster = aws_ecs_cluster.cluster.name
  task_definition = aws_ecs_task_definition.td.arn
  desired_count = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent = 100
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight = 100
  }
  network_configuration {
    security_groups = [aws_security_group.ecs_tasks_sg.id]
    subnets = aws_subnet.private_subnets.*.id
    assign_public_ip = false
  }
}

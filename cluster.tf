# ECS Cluster
resource "aws_ecs_cluster" "cluster" {
  name = "fargate-test"
  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }
}

#!/bin/sh
aws ecr get-login-password --region us-east-2 | \
  docker login --username AWS --password-stdin \
  214161443720.dkr.ecr.us-east-2.amazonaws.com/fargate-test
docker tag fargate-test:latest 214161443720.dkr.ecr.us-east-2.amazonaws.com/fargate-test:latest
docker push 214161443720.dkr.ecr.us-east-2.amazonaws.com/fargate-test:latest

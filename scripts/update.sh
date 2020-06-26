#!/bin/sh
aws ecs update-service --force-new-deployment \
  --region us-east-2 \
  --cluster fargate-test \
  --service fargate-test-service

#!/bin/sh
aws ecs update-service \
  --region us-east-2 \
  --cluster fargate-test \
  --service fargate-test-service \
  --desired-count $@

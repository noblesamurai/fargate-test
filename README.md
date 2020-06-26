# Fargate Test

This repo replicates the setup we have in production except that it only starts a very simple
node application that will log a single `running...` and then wait until the process is killed.

### Dockerfile

The `Dockerfile` is build and pushed to `us-east-2` as `fargate-test`. There are some helper
scripts in the `scripts` directory used to do this once the repository has been created in ECR.

The line to pay attention to is line 22
```
RUN head -c 500M < /dev/urandom > bigfile
```

This is just to make the image large. With this line at 500M it will not start. If this line is
removed or the size is reduced enough it will start working again.

My tests so far have it failing for a 300M file and working for a 250M file.

### Terraform Scripts

To setup the cluster (after the Dockerfile has been published to ECR) using terraform:

```
terraform init
terraform apply
```

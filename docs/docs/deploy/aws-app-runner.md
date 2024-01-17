---
sidebar_position: 2
title: 🏃 AWS App Runner
---

# AWS App Runner 🏃

[App Runner](https://aws.amazon.com/apprunner/) is a fully managed service that makes it easy for developers to quickly deploy containerized web applications and APIs, at scale and with no prior infrastructure experience required. It is service in [Amazon Web Services](https://aws.amazon.com/). App Runner automatically:

- Load balances traffic with encryption
- Scales to meet your traffic needs
- Makes it easy for your services to communicate with other AWS services and applications that run in a private Amazon VPC

## Prerequisites

Before you get started, if you haven't already completed these steps, you'll have to:

1. Create a free [Amazon Web Services account](https://docs.aws.amazon.com/accounts/latest/reference/manage-acct-creating.html)

:::caution
While Amazon Web Services has a free tier that should cover testing projects, you can incur costs when running this quickstart through App Runner or Elastic Container Registry. For more details, see [AWS App Runner Pricing](https://aws.amazon.com/apprunner/pricing/) and [Amazon Elastic Container Registry Pricing](https://aws.amazon.com/ecr/pricing/).
:::

2. Install [Docker](https://docs.docker.com/get-docker/) on your machine, and you'll have to start the app. You can verify it is set up correctly by running:

```bash
docker images
```

(If Docker is running, the command will print the images on your machine. If not, it will print something like `Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?`)

3. Install the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) on your machine.

4. [Configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html) to give it permission to push images. Just make sure the user you configure has the `AmazonEC2ContainerRegistryFullAccess` policy applied.

5. Give Docker permission to push images to AWS by running:

```bash
aws ecr get-login-password --region [REGION] | docker login --username AWS --password-stdin [AWS_ACCOUNT_ID].dkr.ecr.[REGION].amazonaws.com
```

- `[REGION]`: The region you want to deploy to (ex: us-west-1)
- `[AWS_ACCOUNT_ID]`: The id of the account you're deploying to, without dashes (can be found in the top right menu)

6. Create a private Elastic Container Registry (ECR) Repository. This can be done [in the AWS Console](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html), or by running:

```bash
aws ecr create-repository --repository-name [REPOSITORY_NAME]
```

- `[REPOSITORY_NAME]`: A name for the newly created repository.

## Deploying

### 1. Build your API for production use

Simply run:

```bash
dart_frog build
```

This will create a /build directory with all the files needed to deploy your API.

### 2. Build your API using Docker

In order to build a Docker image, you can run this command:

```bash
docker build build \
  --tag [AWS_ACCOUNT_ID].dkr.ecr.[REGION].amazonaws.com/[REPOSITORY_NAME]:[IMAGE_TAG]
```

- `[REGION]`: The region you want to deploy to (ex: us-west-1)
- `[AWS_ACCOUNT_ID]`: The id of the account you're deploying to, without dashes (can be found in the top right menu)
- `[REPOSITORY_NAME]`: The name of the repository you created earlier
- `[IMAGE_TAG]`: A name given to this image to identify it in the repository

It will build the Docker image on your computer, this can take a few seconds to a few minutes.

### 3. Push the image to ECR

Now that you have the image on your computer, you can push it to ECR:

```bash
docker push [AWS_ACCOUNT_ID].dkr.ecr.[REGION].amazonaws.com/[REPOSITORY_NAME]:[IMAGE_TAG]
```

You should now see your repository in the [ECR console](https://console.aws.amazon.com/ecr)

### 4. Create your App Runner Service

Follow [these instructions](https://docs.aws.amazon.com/apprunner/latest/dg/manage-create.html#:~:text=Create%20a%20service%20from%20an%20Amazon%20ECR%20image). Look for the `Create a service from an Amazon ECR image` section.

### 5. Enjoy your API on AWS!

Congratulations 🎉, you have successfully built and deployed your API to App Runner. You can now access your API at the Default domain on the [App Runner console](https://console.aws.amazon.com/apprunner)

## Additional Resources

- [What is AWS App Runner?](https://docs.aws.amazon.com/apprunner/latest/dg/what-is-apprunner.html)
- [Managing custom domain names for an App Runner service](https://docs.aws.amazon.com/apprunner/latest/dg/manage-custom-domains.html)
- [Viewing App Runner logs](https://docs.aws.amazon.com/apprunner/latest/dg/monitor-cwl.html)

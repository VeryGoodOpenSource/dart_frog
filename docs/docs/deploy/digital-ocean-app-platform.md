---
sidebar_position: 3
title: 🌊 Digital Ocean App Platform
---

# Digital Ocean App Platform 🌊

[App Platform](https://www.digitalocean.com/products/app-platform) is a service from [Digital Ocean](https://www.digitalocean.com) that helps you launch apps quickly while they manage the underlying infrastructure.

## Prerequisites

Before you get started, if you haven't already completed these steps, you'll have to:

1. Create a free [Digital Ocean account](https://cloud.digitalocean.com/registrations/new) (or sign in with Google or GitHub).

:::caution
You can incur costs when running this quickstart! For more details, see [App Platform Pricing](https://www.digitalocean.com/pricing/app-platform) and [Container Registry Pricing](https://www.digitalocean.com/pricing/container-registry).
:::

2. Install [Docker](https://docs.docker.com/get-docker/) on your machine and run it. You can verify it is set up correctly by running:

```bash
docker images
```

(If Docker is running, the command will print the images on your machine. If not, it will print something like `Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?`)

3. Install the [Digital Ocean CLI (doctl)](https://docs.digitalocean.com/reference/doctl/how-to/install) on your machine.

4. [Create a Digital Ocean API Token](https://docs.digitalocean.com/reference/api/create-personal-access-token) for your account with read and write access, then use it to give `doctl` access to your account by running (it will prompt you for the access token):

```bash
doctl auth init --context [NAME]
```

- `[NAME]`: A new name for the authentication context.

:::tip
You can switch authentication contexts in `doctl` buy running:

```bash
doctl auth switch --context [NAME]
```

:::

5. Give Docker permission to push images to Digital Ocean by running:

```bash
doctl registry login
```

6. Create a Container Registry. This can be done in the [Digital Ocean console](https://docs.digitalocean.com/products/container-registry/quickstart/#create-a-registry), or by running:

```bash
doctl registry create [REGISTRY_NAME] --region [REGION]
```

- `[REGISTRY_NAME]`: A name for the newly created registry.
- `[REGION]`: The Digital Ocean region the registry should reside in (ex: sfo1)

:::note
Be creative - registry names must be unique across all Digital Ocean container registries.
:::

## Deploying

### 1. Build your API for production use

Simply run:

```bash
dart_frog build
```

This will create a `/build` directory with all the files needed to deploy your API.

### 2. Build your API using Docker

In order to build a Docker image, you can run this command:

```bash
docker build build \
  --tag registry.digitalocean.com/[REGISTRY]/[IMAGE_NAME]
```

- `[REGISTRY]`: The name of the registry you created earlier
- `[IMAGE_NAME]`: A name given to this image to identify it in the registry

This command will build the Docker image on your machine and can take up to a few minutes.

:::caution
Since this step requires building an image on your own hardware make sure the image is compatible with the hardware used by Digital Ocean before proceeding.

For example, if you build on an M1 CPU, the generated image will not be able to run on an Intel CPU.
:::

:::info
We recommend using an automated workflow via GitHub Actions to automate deployments and ensure a consistent environment when building your image.
:::

### 3. Push the image to Container Registry

```bash
docker push registry.digitalocean.com/[REGISTRY]/[IMAGE_NAME]
```

You should now see your repository in the [Container Registry page](https://cloud.digitalocean.com/registry)

### 4. Create your App

Create an application on Digital Ocean by following [these instructions](https://docs.digitalocean.com/products/app-platform/how-to/deploy-from-container-images/#deploy-resource-using-a-container-image-as-the-source).

### 5. Enjoy your API on Digital Ocean!

Congratulations 🎉, you have successfully built and deployed your API to App Platform. You can now access your API via the URL at the top of the app’s overview page 🎉

## Additional Resources

- [App Platform docs](https://docs.digitalocean.com/products/app-platform)
- [`doctl` CLI reference](https://docs.digitalocean.com/reference/doctl)
- [Adding a custom domain in App Platform](https://docs.digitalocean.com/products/app-platform/how-to/manage-domains)
- [View logs in App Platform](https://docs.digitalocean.com/products/app-platform/how-to/view-logs)

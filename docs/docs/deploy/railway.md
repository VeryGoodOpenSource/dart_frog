---
sidebar_position: 5
title: 🛤️ Railway
---

# Railway 🛤️

[Railway](https://railway.app) is a cloud platform that can build, deploy, and monitor your HTTP applications (like APIs made with Dart Frog) with minimal setup. It embraces private networks so you can link databases with other services easily and securely without needing much knowledge of network security. It also features:

- Secret management
- Autoscaling (both vertically and horizontally), as well as sleeping services when not in use.
- Auto deployment from GitHub
- Usage based pricing
- Hundreds of templates for quickly deploying ready-to-use software
- Health checks, instant rollbacks, environments, and more

This guide will show you how to auto-build-and-deploy to Railway using it's integrated build system. However, Railway is also able to deploy pre-built Docker images. You could also build your application in an external system (like GitHub Actions) and [deploy to Railway with that image](https://docs.railway.app/overview/the-basics#services).

## Prerequisites

Before you get started, if you don't already have these, you'll need to create:

- A [free Railway account](https://railway.app)
- A [Railway project](https://railway.app/dashboard)

:::caution
At the time of writing, Railway has a free tier that allows you to experiment with their platform. However, you are responsible for any costs that may incur with this tutorial. For more details, see the [Railway Pricing Page](https://railway.app/pricing).
:::

In addition, your Dart Frog project must include `dart_frog_cli` in your `dev_dependencies`. This is so that you can run `dart_frog build` without needing to instal the cli. Just add it like this:

```yaml
dev_dependencies:
  dart_frog_cli:
```

## Deploying

### 1. Create the Service

To start, in your Railway project, [create a new service connected to your repository](https://docs.railway.app/guides/services#creating-a-service). You'll have to connect to your GitHub account to select the repository.

:::tip
If your repository is a _monorepo_ and your Dart Frog project is not the project's root directory, you can specify it's directory in the `Add Root Directory` setting under the `Source Repo` settings.
:::

### 2. Configure the Settings

Scroll to the `Build` section. Adjust these settings: - For `Providers`, Railway should have already detected `Dart` as the language. If it hasn't, add it using the plus button. - For `Custom Build Command`, enter the following command, then click the checkmark to save the setting.

```bash
dart run dart_frog_cli:dart_frog build && dart compile exe build/bin/server.dart -o build/bin/server
```

Scroll to the `Deploy` section. For `Custom Start Command`, set the value the following command, then click the checkmark to save the setting.

```bash
./build/bin/server
```

:::note
There are a bunch of other settings to further configure your deployments. For more information, see the [Railway Deployment Guides](https://docs.railway.app/guides/deployments).
:::

### 3. Deploy

On the main area to the left of configuration, you should see a dialog saying _Apply X Changes_ with a deploy button. Click `Deploy`. After a few minutes, you deployment should finish successfully! 🎉

:::tip
If you are building an external service, such as an API or website, be sure to enable a public domain under the `Networking` settings. For more info, see the [Public Networking Guide](https://docs.railway.app/guides/public-networking).
:::

## Additional Resources

- [Railway Docs](https://docs.railway.app)
- [Logging and Monitoring Docs](https://docs.railway.app/guides/logs)
- [Configuring Health Checks](https://docs.railway.app/guides/healthchecks-and-restarts)
- [Connecting Databases](https://docs.railway.app/guides/databases)
- [Nixpacks Docs (used behind the scenes)](https://nixpacks.com/docs)

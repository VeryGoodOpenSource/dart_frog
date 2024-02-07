---
sidebar_position: 4
title: 💎 Clever Cloud
---

# Clever Cloud 💎

[Clever Cloud](https://www.clever-cloud.com/) is a PaaS provider that enables you to start apps quickly using `git` while they manage the infrastructure, scalability, and run lifetime.

## Prerequisites

Before you get started, if you don't already have these, you'll need to create:

- A [Clever Cloud Account](https://api.clever-cloud.com/v2/sessions/signup)
- Add billing information

:::caution
As with any PaaS service you should check the pricing before continuing. Clever Cloud has a transparent pricing policy depending on the runtime type and size, see the [Clever Cloud Pricing Page](https://www.clever-cloud.com/pricing/).
:::

You might be able to do everything in the console, but for this tutorial, we will use the [Clever Cloud CLI](https://www.clever-cloud.com/doc/reference/clever-tools/getting_started/), so you'll have to install it on your computer.

Then log in running:

```bash
clever login
```

## Deploying

### 1. Create the Clever Cloud application

_Clever Cloud_ has [many available runtime](https://www.clever-cloud.com/product/) that are optimized for the type of application you want to deploy. Unfortunately, **dart** is **not** _yet_ one of them.

In order to deploy those type of applications, there is a [_Docker_ runtime](https://www.clever-cloud.com/doc/deploy/application/docker/docker/) available, and we will this one.

So, first things first, lets create a _Docker_ runtime:

:::tip
Make sure you are at the root of your project and not in `build`, as this command will produce a `.clever.json` file in the current folder.
:::

```bash
clever create --type docker <app-name> --region <zone> --org <org>
```

For example, if the project's name is _api_ and you want it to be deployed in _Paris_ (par), you can run:

```bash
clever create --type docker api --region par
```

The `<org>` argument is optional if you only have one Clever Cloud organization.
:::note
For a full list of all the available zones refer to [Clever Cloud's zones list](https://www.clever-cloud.com/blog/features/2020/11/05/ovh-clever-cloud-zones/).

:::

As a result, you should have `Your application has been successfully created!`

If you check your project's file, you'll find a `.clever.json` file containing something like this:

```json
{
  "apps": [
    {
      "app_id": "app_<some_id>",
      "org_id": "<org>",
      "deploy_url": "https://<some_src>.services.clever-cloud.com/app_<some_id>.git",
      "name": "<app-name>",
      "alias": "<app-name>"
    }
  ]
}
```

:::note
You **can** add this file to your git repository.
:::

:::tip
By default, the runtime is scaled to **XS**, which is 1 CPU / 1Gio RAM, if you want to scale it down for testing purposes you can use the following:

```bash
clever scale --flavor nano
```

Giving the output `App rescaled successfully`
:::

### 2. Deploy your API to Clever Cloud

As Clever Cloud uses `git` we don't have to compile binaries and share them, Clever Cloud handles that for us, making the deployment steps as followed:

    (0. send the sources)
    1. build the app
    2. run the app

:::note
_Clever Cloud_ listens on port `8080` by default which is also Dart Frog's default port, it works out of the box!
:::

In order to tell _Clever Cloud_ how to build our project, we will need to create a `Dockerfile`, because the one created by `dart_frog build` is a built item and not sent to _Clever Cloud_ with _git_.

Here is the `Dockerfile` you can add at the root of your project.

```docker
# This stage will compile sources to get the build folder
FROM dart:stable AS build

# Install the dart_frog cli from pub.dev
RUN dart pub global activate dart_frog_cli

# Set the working directory
WORKDIR /app

# Copy Dependencies in our working directory
COPY pubspec.* /app/
COPY routes /app/routes
# Uncomment the following line if you are serving static files.
# COPY --from=build public /app/public

# Add all of your custom directories here, for example if you have a "models" directory:
# COPY models /app/models

# Get dependencies
RUN dart pub get

# 📦 Create a production build
RUN dart_frog build

# Compile the server to get the executable
RUN dart compile exe /app/build/bin/server.dart -o /app/build/bin/server

# Build minimal serving image from AOT-compiled `/server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch

COPY --from=build /runtime/ /
COPY --from=build /app/build/bin/server /app/bin/server
# Uncomment the following line if you are serving static files.
# COPY --from=build /app/build/public /public/

# Expose the server port (useful for binding)
EXPOSE 8080

# Run the server
CMD ["/app/bin/server"]
```

:::tip
If you already have a `Dockerfile` you can rename it and specify to _Clever Cloud_ that the docker file to run is not `Dockerfile`:

```bash
clever env set CC_DOCKERFILE <the  name of your file>
```

:::

Add the newly created `Dockerfile` to `git` via `git add Dockerfile`, commit and then run:

```bash
clever deploy
```

Your **source code** will be sent to Clever Cloud.

:::warning
Consider Clever Cloud like a new [remote (from a git point of view)](https://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes) and clever deploy a git push.
:::

And watch the magic happening

```
App is brand new, no commits on remote yet
New local commit to push is XXX (from refs/heads/main)
Pushing source code to Clever Cloud…
Your source code has been pushed to Clever Cloud.
Waiting for deployment to start…
Deployment started (deployment_XXX)
Waiting for application logs…
...
...
Deployment successful
```

### 3. Enjoy your API on Clever Cloud! 🎉

You have successfully built and deployed your API to _Clever Cloud_

To access your app you can go to

`https://app-\<your app id\>.cleverapps.io/`

:::tip
Your app's id is in the `.clever.json` file.

Please note that the app id is `app_XX` and the url is `app-XX` (underscore in file, hyphen in url).
:::

## Additional Resources

- [What is Clever Cloud](https://www.clever-cloud.com/presentation/)
- [Clever Cloud Pricing](https://www.clever-cloud.com/pricing/)
- [Clever Cloud Doc](https://www.clever-cloud.com/doc/)
- [Clever Cloud CLI](https://www.clever-cloud.com/doc/getting-started/cli/)

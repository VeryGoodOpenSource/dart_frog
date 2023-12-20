---
sidebar_position: 4
title: 🌐 Globe
---

# Globe 🌐

[Globe](https://globe.dev/) is a deployment platform for Dart developers, that allows you to deploy your Dart Frog backend to a globally distributed service without the need to manage servers, networks, or scaling. They provides a seamless developer experience for deploying and managing Dart Frog projects.

## Prerequisites

Before you get started, if you don't already have a [free Globe Account](https://globe.dev/login), you'll need to create one.

:::info
Globe is currently in public preview.
:::

Additionally, you'll need the [`globe` command line interface (CLI)](https://docs.globe.dev/cli#installation) installed on your computer.

Finally, you'll want to log in to `globe` by running:

```bash
globe login
```

## Deploying

1. Deploy your API for production use by running:

```bash
globe deploy --prod
```

2. Congratulations! 🎉 You have successfully deployed your API to Globe. You can now access your API at the Deployment URL that is available through the Globe dashboard.

## Additional Resources

- [Globe documentation](https://docs.globe.dev/)
- [`globe deploy` documentation](https://docs.globe.dev/cli/commands/deploy)
- [Globe's Dart Frog documentation](https://docs.globe.dev/frameworks/dart-frog)

---
sidebar_position: 1
title: ☁️ Google Cloud Run
---

# Google Cloud Run ☁️

[Cloud Run](https://cloud.google.com/run) is a service in the [Google Cloud Platform](https://cloud.google.com/) that allows you to deploy highly scalable containerized applications using your favorite language on a fully managed serverless platform. You can use Cloud Run to serve requests from your Dart Frog API to the internet. This will provide:

- Fully managed autoscaling to handle any number of requests
- Only pay for the computing resources you use, and pay nothing when your service isn't being used
- Automatic logging in [Cloud Logging](https://cloud.google.com/logging)

## Prerequisites

Before you get started, if you don't already have these, you'll need to create:

- A [free Google Account](https://support.google.com/accounts/answer/27441?hl=en)
- A [Google Cloud Platform (GCP) Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects)
- A [billing account](https://cloud.google.com/billing/docs/how-to/manage-billing-account#create_a_new_billing_account) connected to your GCP project

:::caution
While the Google Cloud Platform has a free tier that should cover testing projects, you can incur costs when running this quickstart through Cloud Run, Cloud Build, or Artifact Registry. For more details, see the [Google Cloud Price List](https://cloud.google.com/pricing/list).
:::

Additionally, you'll need the [`gcloud` command line interface (CLI)](https://cloud.google.com/sdk/docs/install) installed on your computer.

Finally, you'll want to log in to `gcloud` by running:

```bash
gcloud auth login
```

## Deploying

1. Build your API for production use by running:

```bash
dart_frog build
```

This will create a `/build` directory with all the files needed to deploy your API.

2. Deploy your API to Cloud Run by running:

```bash
gcloud run deploy [SERVICE_NAME] \
  --source build \
  --project=[PROJECT_ID] \
  --region=[REGION] \
  --allow-unauthenticated
```

- `[SERVICE_NAME]`: The name of the Cloud Run service you want to create/update
- `[PROJECT_ID]`: The ID of the Google Cloud project
- `[REGION]`: The GCP region you wish to deploy to (ex: us-central1)

:::caution
There is an ongoing [issue](https://github.com/google/gvisor/issues/7331) that is preventing Dart Unix Sockets from working correctly in the gen1 version of the [Cloud Run execution environment](https://cloud.google.com/run/docs/about-execution-environments). In that case, it is recommended to deploy to gen2 by adding `--execution-environment=gen2`.
:::

Running this command will do three things:

- Upload the code in the `/build` directory
- Build the Docker image in [Cloud Build](https://cloud.google.com/build) and upload it to [Artifact Registry](https://cloud.google.com/artifact-registry)
- Deploy the image to the specified Cloud Run service

3. Congratulations! 🎉 You have successfully built and deployed your API to Cloud Run. You can now access your API at the Service URL that is printed in the last line of output.

:::note
If you have not already enabled the necessary Google Cloud APIs to deploy your API, `gcloud` can enable them for you. Just select `Y` when prompted.
:::

:::tip
You can save the project ID and region to `gcloud` so you don't have to specify them each time you deploy.

```bash
gcloud config set core/project [PROJECT_ID]
gcloud config set run/region [REGION]
```

:::

Example:

```bash
$ gcloud run deploy hello  --source build --allow-unauthenticated

Building using Dockerfile and deploying container to Cloud Run service [hello] in project [dart-demo] region [us-central1]
✓ Building and deploying new service... Done.
  ✓ Uploading sources...
  ✓ Building Container... Logs are available at [https://console.cloud.google.com/cloud-build/builds/df7f07d1-d88b-4443-a2b1-bdfd3cdab15b?project=700116488077].
  ✓ Creating Revision... Revision deployment finished. Waiting for health check to begin.
  ✓ Routing traffic...
  ✓ Setting IAM Policy...
Done.
Service [hello] revision [hello-00001-yen] has been deployed and is serving 100 percent of traffic.
Service URL: https://hello-gpua4upw6q-uc.a.run.app
```

## Additional Resources

- [What is Cloud Run](https://cloud.google.com/run/docs/overview/what-is-cloud-run)
- [`gcloud run deploy` documentation](https://cloud.google.com/sdk/gcloud/reference/run/deploy)
- [Cloud Run automatic logging](https://cloud.google.com/run/docs/logging)
- [Mapping custom domains to Cloud Run](https://cloud.google.com/run/docs/mapping-custom-domains)

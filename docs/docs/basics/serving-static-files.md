---
sidebar_position: 6
---

# Serving Static Files 📁

Dart Frog supports serving static files including images, text, json, html, and more. To serve static files, place the files within the `public` directory at the root of the project.

For example, if you create a file in `public/hello.txt` which contains the following:

```
Hello World!
```

The contents of the file will be available at [http://localhost:8080/hello.txt](http://localhost:8080/hello.txt).

The `public` directory can also contain static files within subdirectories. For example, if you create an image in `public/images/unicorn.png`, the contents of the file will be available at [http://localhost:8080/images/unicorn.png](http://localhost:8080/images/unicorn.png).

When running a development server, static files can be added, removed, and modified without needing to restart the server thanks to hot reload ⚡️.

:::note
Static file support requires `dart_frog ^0.0.2-dev.7` and `dart_frog_cli ^0.0.1-dev.8`
:::

:::note
The `/public` folder must be at the root of the project and cannot be renamed. This is the only directory used to serve static files.
:::

:::note
In production, only files that are in the `/public` directory at build time will be served.
:::

:::caution
Be sure not to have a static file with the same name as a file in the `/routes` directory as this will result in a conflict.
:::

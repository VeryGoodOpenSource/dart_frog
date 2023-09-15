import TOCInline from '@theme/TOCInline';

# 🧰 Daemon

Dart Frog daemon is a standing process that, during its lifetime, will be used by first and
third-party tools to manage, build, and diagnose Dart Frog projects.

By design, the daemon is able to manage multiple projects simultaneously; it can also run multiple
application instances of the same project if necessary.

To start using it, install the Dart Frog CLI and run the `dart_frog daemon` command. Once running, communicating with it can be done via [JSON-RPC](https://www.jsonrpc.org/) over stdin/stdout to receive and send messages.

There are three types of messages:

- **Request**: A request is a message sent by a client to the daemon. The daemon will process the
  request and send a response back to the client. A request is essentially a method invocation.
- **Response**: A response is a message sent by the daemon to a client in response to a request.
- **Event**: An event is a message sent by the daemon to a client. The daemon will send an event to
  a client when something happens, for example, when a running dev server stops.

Every request should be met with a response as soon as possible so the caller can work with
timeouts. The daemon will send events to the client as they happen.

---

#### Usage example

```sh
$ dart_frog daemon

// ready event sent via stdout
[{"event":"daemon.ready","params":{"version":"0.0.1","processId":75941}}]

// request inserted via stdin
[{"method": "daemon.requestVersion", "id": "12"}]

// response sent via stdout
[{"id":"12","result":{"version":"0.0.1"}}]
```

The `id` field on the request is used to match the request with the response. As the client sets it arbitrarily, the client is responsible for ensuring that all request ids are unique.

:::warning
The requests should be strictly in the format `[{...}]`. Therefore, sending a request with any of these formats: `[{...},]`, `[{...}, {...}]` or `[{...}]\n[{...}]` is currently not accepted.
:::

---

# Domains

To organize the accepted requests and its parameters as well as events, there are "domains." A
domain is a group of related requests and events.

The domains are:

<TOCInline toc={toc} />

## `daemon` domain

The `daemon` domain is used to manage the daemon itself.

### Method: `requestVersion`

Request the daemon version.

- **Response**:

| Field   | type   | Description        |
| ------- | ------ | ------------------ |
| version | string | The daemon version |

### Method: `kill`

Shuts down the daemon

- **Response**:

| Field   | type   | Description       |
| ------- | ------ | ----------------- |
| message | string | A goodbye message |

### Event: `ready`

Signals that a daemon is ready right after startup

- **Content**:

| Field     | type   | Description                                   |
| --------- | ------ | --------------------------------------------- |
| version   | string | The daemon version                            |
| processId | int    | The process id in which the daemon is running |

## `dev_server` domain

Operations related to running/managing Dart Frog dev servers locally.

### Method: `start`

Start a dev server on a given project.

- **Parameters**:

| Field             | Type   | Description                            | Required |
| ----------------- | ------ | -------------------------------------- | -------- |
| workingDirectory  | String | The project directory                  | Yes      |
| port              | int    | The port to run the dev server on      | Yes      |
| dartVmServicePort | int    | The port to run the Dart VM Service on | Yes      |

- **Response**:

| Field         | Type   | Description                                     |
| ------------- | ------ | ----------------------------------------------- |
| applicationId | String | A unique identifier for the dev server instance |

### Method: `reload`

Reload a running dev server.

- **Parameters**:

| Field         | Type   | Description               | Required |
| ------------- | ------ | ------------------------- | -------- |
| applicationId | String | The dev server identifier | Yes      |

- **Response**:

| Field         | Type   | Description                                     |
| ------------- | ------ | ----------------------------------------------- |
| applicationId | String | A unique identifier for the dev server instance |

### Method: `stop`

Stop a running dev server.

- **Parameters**:

| Field         | Type   | Description               | Required |
| ------------- | ------ | ------------------------- | -------- |
| applicationId | String | The dev server identifier | Yes      |

- **Response**:

| Field         | Type   | Description                                     |
| ------------- | ------ | ----------------------------------------------- |
| applicationId | String | A unique identifier for the dev server instance |
| exitCode      | int    | The exit code of the dev server process         |

### Event: `applicationStarting`

Signals that a dev server is starting.

- **Content**:

| Field         | Type   | Description                                                     |
| ------------- | ------ | --------------------------------------------------------------- |
| applicationId | String | A unique identifier for the dev server instance                 |
| requestId     | String | A unique identifier for the request that started the dev server |

### Event: `applicationExit`

Signals that a dev server has exited.

- **Content**:

| Field         | Type   | Description                                                     |
| ------------- | ------ | --------------------------------------------------------------- |
| applicationId | String | A unique identifier for the dev server instance                 |
| requestId     | String | A unique identifier for the request that started the dev server |
| exitCode      | int    | The exit code of the dev server process                         |

### Dev server logging events

The dev server will send logging events to the client as they happen. These events are identified by
"dev_server.logger<Severity\>". See the [Logging events](#logging-events) section for more details.

- **Content**:

| Field            | Type   | Description                                                     |
| ---------------- | ------ | --------------------------------------------------------------- |
| applicationId    | String | A unique identifier for the dev server instance                 |
| requestId        | String | A unique identifier for the request that started the dev server |
| workingDirectory | String | The project directory                                           |
| message          | String | The log message                                                 |

## `route_configuration` domain

Operations related to the route configuration of a project.

A route configuration is generated from the files under `routes` as it describes which routes are
available in the project as well as the location of middlewares. The route configuration is
used to diagnose the project for issues such as rogue routes and path conflicts.

### Method: `watcherStart`

Starts a route configuration watcher for a given project. The watcher will send events to the client
when the route configuration of a project changes.

- **Parameters**:

| Field            | Type   | Description           | Required |
| ---------------- | ------ | --------------------- | -------- |
| workingDirectory | String | The project directory | Yes      |

- **Response**:

| Field     | Type   | Description                                  |
| --------- | ------ | -------------------------------------------- |
| watcherId | String | A unique identifier for the watcher instance |

### Method: `watcherStop`

Stops a route configuration watcher created by `watcherStart`.

- **Parameters**:

| Field     | Type   | Description                                  | Required |
| --------- | ------ | -------------------------------------------- | -------- |
| watcherId | String | A unique identifier for the watcher instance | Yes      |

- **Response**:

| Field     | Type   | Description                                  |
| --------- | ------ | -------------------------------------------- |
| watcherId | String | A unique identifier for the watcher instance |
| exitCode  | int    | The exit code of the watcher process         |

### Method: `watcherGenerateRouteConfiguration`

Forces a route configuration watcher to generate a route configuration for a given project.
Also, returns the generated route configuration.

- **Parameters**:

| Field     | Type   | Description                                  | Required |
| --------- | ------ | -------------------------------------------- | -------- |
| watcherId | String | A unique identifier for the watcher instance | Yes      |

- **Response**:

| Field              | Type   | Description                                  |
| ------------------ | ------ | -------------------------------------------- |
| watcherId          | String | A unique identifier for the watcher instance |
| routeConfiguration | String | The generated route configuration            |

### Event: `changed`

Signals that the route configuration of a project has changed.

- **Content**:

| Field              | Type   | Description                                                  |
| ------------------ | ------ | ------------------------------------------------------------ |
| watcherId          | String | A unique identifier for the watcher instance                 |
| requestId          | String | A unique identifier for the request that started the watcher |
| routeConfiguration | String | The generated route configuration                            |

### Event: `watcherStart`

Signals that a route configuration watcher has started.

- **Content**:

| Field            | Type   | Description                                  |
| ---------------- | ------ | -------------------------------------------- |
| watcherId        | String | A unique identifier for the watcher instance |
| requestId        | String | A unique identifier for the request          |
| workingDirectory | String | The project directory                        |

### Event: `watcherExit`

Signals that a route configuration watcher has exited.

- **Content**:

| Field            | Type   | Description                                  |
| ---------------- | ------ | -------------------------------------------- |
| watcherId        | String | A unique identifier for the watcher instance |
| requestId        | String | A unique identifier for the request          |
| workingDirectory | String | The project directory                        |
| exitCode         | int    | The exit code of the watcher process         |

### Route configuration watcher logging events

Each watcher instance will send logging events to the client as they happen. These events are identified by
"route_configuration.logger<Severity\>". See the [Logging events](#logging-events) section for more details.

- **Content**:

| Field            | Type   | Description                                                  |
| ---------------- | ------ | ------------------------------------------------------------ |
| watcherId        | String | A unique identifier for the watcher instance                 |
| requestId        | String | A unique identifier for the request that started the watcher |
| workingDirectory | String | The project directory                                        |
| message          | String | The log message                                              |

# Logging events

Some operations (eg. starting a dev server) will generate logs. These logs are sent to the client
via logging events. These events are identified by the "logger" prefix on its name followed by its
severity. Its domain is always associated with the operation that generated the log.

For example, this is logger event generate bhy the `dev_server.start` operation
(the content was formatted to improve readability):

```json
[
  {
    "event": "dev_server.loggerInfo",
    "params": {
      "applicationId": "cfd5d56a-b855-49a7-9153-a035b1ba1bc4",
      "requestId": "2",
      "workingDirectory": "/path/to/project",
      "message": "The Dart VM service is listening on http://127.0.0.1:8091/fWMHu3sTnYk=/"
    }
  }
]
```

In this example, it is a logger event with the `info` severity. The `params` field contains the
metadata associated with the event. In this case, the `applicationId` and `requestId` fields
can be used to identify the operation that generated the log.

The available severities are:

| level    | identification                                        |
| -------- | ----------------------------------------------------- |
| debug    | `loggerDetail`                                        |
| info     | `loggerInfo` <br/> `loggerSuccess`<br/> `loggerWrite` |
| warn     | `loggerWarning`                                       |
| error    | `loggerError`                                         |
| critical | `loggerAlert`                                         |

---

Associated with logging, there is also the progress loggings. These are used to signal the
progress of a long-running operation. For example, when generating server code. These events
are identified by the "progress" prefix on its name. Its domain is always associated with the
operation that generated the log. The identifiers are associated not with severity but with
its progress. The available identifiers are:

| identifier         | details                                                                                                                                         |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `progressStart`    | Identifies the start of the progress. Its params include `progressId` which can be used to track further events associated with this operation. |
| `progressUpdate`   | Identifies an update on the progress.                                                                                                           |
| `progressCancel`   | Progress was cancelled. Ends the progress.                                                                                                      |
| `progressFail`     | Progress has failed. Ends the progress.                                                                                                         |
| `progressComplete` | Progress has completed. Ends the progress.                                                                                                      |

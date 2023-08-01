import TOCInline from '@theme/TOCInline';

# 🧰 Daemon

Dart frog daemon is a standing process that, during its lifetime, will be used by first and
third-party tools to manage, build, and diagnose dart frog projects.

By design, a daemon is able to manage multiple projects simultaneously. The daemon can run multiple
application instances of the same project if necessary.

The daemon can be started by running the `dart_frog daemon` command. The daemon
uses [JSON-RPC](https://www.jsonrpc.org/) over stdin/stdout to receive and send messages.

The messages can be sorted in three types:

- **Request**: A request is a message sent by a client to the daemon. The daemon will process the
  request and send a response back to the client. A request is essentially a method invocation.
- **Response**: A response is a message sent by the daemon to a client in response to a request.
- **Event**: An event is a message sent by the daemon to a client. The daemon will send an event to
  a client when something happens, for example, when a running dev server stops.

Every request should be met with a response as soon as possible so the caller can work with
timeouts. The daemon will send events to the client as they happen.

---

#### Usage example

```json
$ dart_frog daemon

// ready event sent via stdout
[{"event":"daemon.ready","params":{"version":"0.0.1","processId":75941}}]

// request inserted via stdin
[{"method": "daemon.requestVersion", "id": "12"}]

// response sent via stdout
[{"id":"12","result":{"version":"0.0.1"}}]

```

The `id` field on the request is used to match the request with the response. As the client sets it arbitrarily, the client is responsible for ensuring that the id is unique.

---

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

| Field         | Type   | Description                                    |
| ------------- | ------ | ---------------------------------------------- |
| applicationId | String | A unique identifier for the devserver instance |

### Method: `reload`

Reload a running dev server.

- **Parameters**:

| Field         | Type   | Description              | Required |
| ------------- | ------ | ------------------------ | -------- |
| applicationId | String | The devserver identifier | Yes      |

- **Response**:

| Field         | Type   | Description                                    |
| ------------- | ------ | ---------------------------------------------- |
| applicationId | String | A unique identifier for the devserver instance |

### Method: `stop`

Stop a running dev server.

- **Parameters**:

| Field         | Type   | Description              | Required |
| ------------- | ------ | ------------------------ | -------- |
| applicationId | String | The devserver identifier | Yes      |

- **Response**:

| Field         | Type   | Description                                    |
| ------------- | ------ | ---------------------------------------------- |
| applicationId | String | A unique identifier for the devserver instance |
| exitCode      | int    | The exit code of the devserver process         |

### Event: `applicationStarting`

Signals that a dev server is starting.

- **Content**:

| Field         | Type   | Description                                                    |
| ------------- | ------ | -------------------------------------------------------------- |
| applicationId | String | A unique identifier for the devserver instance                 |
| requestId     | String | A unique identifier for the request that started the devserver |

### Event: `applicationExit`

Signals that a dev server has exited.

- **Content**:

| Field         | Type   | Description                                                     |
| ------------- | ------ | --------------------------------------------------------------- |
| applicationId | String | A unique identifier for the dev server instance                 |
| requestId     | String | A unique identifier for the request that started the dev server |
| exitCode      | int    | The exit code of the dev server process                         |

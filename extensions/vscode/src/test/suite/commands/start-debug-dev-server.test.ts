const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";
import { DartFrogApplication } from "../../../daemon";

suite("start-debug-dev-server command", () => {
  const application: DartFrogApplication = new DartFrogApplication(
    "workingDirectory",
    8080,
    8181
  );
  application.id = "applicationId";
  application.vmServiceUri = "vmServiceUri";

  let commandsStub: any;
  let command: any;

  beforeEach(() => {
    commandsStub = {
      startDevServer: sinon.stub().resolves(application),
      debugDevServer: sinon.stub().resolves(),
    };

    command = proxyquire("../../../commands/start-debug-dev-server", {
      // eslint-disable-next-line @typescript-eslint/naming-convention
      ".": commandsStub,
    });
  });

  afterEach(() => {
    sinon.restore();
  });

  test("starts server and debug session", async () => {
    await command.startDebugDevServer();

    sinon.assert.calledOnce(commandsStub.startDevServer);

    sinon.assert.calledOnce(
      commandsStub.debugDevServer.withArgs(
        sinon.match({
          application: application,
        })
      )
    );
  });

  test("does not start debug session when failed to start", async () => {
    commandsStub.startDevServer.resolves();

    await command.startDebugDevServer();

    sinon.assert.calledOnce(commandsStub.startDevServer);

    sinon.assert.calledOnce(
      commandsStub.debugDevServer.withArgs(
        sinon.match({
          application: application,
        })
      )
    );
  });
});

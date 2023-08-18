import * as assert from "assert";
import { DartFrogApplication } from "../../../daemon";

suite("DartFrogApplication", () => {
  const projectPath = "/path/to/project";
  const port = 8080;
  const vmServicePort = 8081;

  test("constructor sets properties", () => {
    const application = new DartFrogApplication(
      projectPath,
      port,
      vmServicePort
    );

    assert.equal(application.projectPath, projectPath);
    assert.equal(application.port, port);
    assert.equal(application.vmServicePort, vmServicePort);
  });

  suite("id", () => {
    test("is undefined by default", () => {
      const application = new DartFrogApplication(
        projectPath,
        port,
        vmServicePort
      );

      assert.equal(application.id, undefined);
    });

    test("can be set", () => {
      const application = new DartFrogApplication(
        projectPath,
        port,
        vmServicePort
      );

      application.id = "1";

      assert.equal(application.id, "1");
    });

    test("cannot be set more than once", () => {
      const application = new DartFrogApplication(
        projectPath,
        port,
        vmServicePort
      );

      application.id = "1";
      application.id = "2";

      assert.equal(application.id, "1");
    });
  });

  suite("vmServiceUri", () => {
    test("is undefined by default", () => {
      const application = new DartFrogApplication(
        projectPath,
        port,
        vmServicePort
      );

      assert.equal(application.vmServiceUri, undefined);
    });

    test("can be set", () => {
      const application = new DartFrogApplication(
        projectPath,
        port,
        vmServicePort
      );

      application.vmServiceUri = "http://localhost:8081";

      assert.equal(application.vmServiceUri, "http://localhost:8081");
    });

    test("cannot be set more than once", () => {
      const application = new DartFrogApplication(
        projectPath,
        port,
        vmServicePort
      );

      application.vmServiceUri = "http://localhost:8081";
      application.vmServiceUri = "http://localhost:8082";

      assert.equal(application.vmServiceUri, "http://localhost:8081");
    });
  });

  suite("address", () => {
    test("is undefined by default", () => {
      const application = new DartFrogApplication(
        projectPath,
        port,
        vmServicePort
      );

      assert.equal(application.address, undefined);
    });

    test("can be set", () => {
      const application = new DartFrogApplication(
        projectPath,
        port,
        vmServicePort
      );

      application.address = "http://localhost:8080";

      assert.equal(application.address, "http://localhost:8080");
    });

    test("cannot be set more than once", () => {
      const application = new DartFrogApplication(
        projectPath,
        port,
        vmServicePort
      );

      application.address = "http://localhost:8080";
      application.address = "http://localhost:8081";

      assert.equal(application.address, "http://localhost:8080");
    });
  });
});

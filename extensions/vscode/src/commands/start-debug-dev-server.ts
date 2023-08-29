import { DebugDevServerOptions, debugDevServer } from ".";
import { startDevServer } from "./start-dev-server";

/**
 * Starts a Dart Frog application and immediately attaches a debugger to it.
 *
 * @returns A promise that resolves when the server has been started and a debug
 * session has been created.
 */
export const startDebugDevServer = async (): Promise<void> => {
  const application = await startDevServer();
  if (!application) {
    return;
  }

  const debugOptions: DebugDevServerOptions = {
    application: application,
  };
  await debugDevServer(debugOptions);
};

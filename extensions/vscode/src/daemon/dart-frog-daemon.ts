/**
 * The Dart Frog daemon is a long-running process that is responsible for
 * managing a single or multiple Dart Frog projects simultaneously.
 *
 * @see {@link https://dartfrog.vgv.dev/docs/advanced/daemon Dart Frog deamon documentation }
 */
export class DartFrogDaemon {
  private static _instance: DartFrogDaemon;

  /**
   * A singleton instance of the Dart Frog daemon.
   *
   * A Dart Frog daemon can manage multiple Dart Frog projects simultaneously.
   */
  public static get instance() {
    return this._instance || (this._instance = new this());
  }
}

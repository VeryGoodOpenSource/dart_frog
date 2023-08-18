export abstract class IdentifierGenerator {
  /**
   * Generates a new unique identifier.
   *
   * @returns A new unique identifier, consecutive calls to this method should
   * always return different identifiers.
   */
  abstract generate(): string;
}

/**
 * Generates incremental identifiers.
 *
 * @example
 * const generator = new AscendingNumericalIdentifierGenerator();
 * generator.generate(); // "0"
 * generator.generate(); // "1"
 */
export class AscendingNumericalIdentifierGenerator
  implements IdentifierGenerator
{
  private counter: bigint = 0n;

  public generate(): string {
    return `${this.counter++}`;
  }
}

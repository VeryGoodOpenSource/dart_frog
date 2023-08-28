import * as assert from "assert";
import { AscendingNumericalIdentifierGenerator } from "../../../utils";

suite("AscendingNumericalIdentifierGenerator", () => {
  suite("generate", () => {
    test("generates identifiers in ascending order", () => {
      const generator = new AscendingNumericalIdentifierGenerator();

      const identifiers = [];
      for (let i = 0; i < 100; i++) {
        identifiers.push(generator.generate());
      }

      assert.deepStrictEqual(identifiers, identifiers.sort());
    });

    test("generates unique identifiers", () => {
      const generator = new AscendingNumericalIdentifierGenerator();

      const identifiers = [];
      for (let i = 0; i < 100; i++) {
        identifiers.push(generator.generate());
      }

      assert.deepStrictEqual(identifiers.length, new Set(identifiers).size);
    });

    test("generates numerical identifiers", () => {
      const generator = new AscendingNumericalIdentifierGenerator();

      const identifiers = [];
      for (let i = 0; i < 100; i++) {
        identifiers.push(generator.generate());
      }

      assert.equal(
        identifiers.every((id) => /^\d+$/.test(id)),
        true
      );
    });
  });
});

import 'package:dart_frog_new_hooks/src/parameter_syntax.dart';
import 'package:test/test.dart';

void main() {
  group('ParameterSyntax', () {
    group('toDiamondParameterSyntax', () {
      test('should convert brackets to diamond brackets', () {
        expect('/[id]'.toDiamondParameterSyntax, equals('/<id>'));
        expect('/[id]/item'.toDiamondParameterSyntax, equals('/<id>/item'));
        expect('/top/[id]'.toDiamondParameterSyntax, equals('/top/<id>'));
      });
    });
    group('toBracketParameterSyntax', () {
      test('should convert diamond brackets to brackets', () {
        expect('/<id>'.toBracketParameterSyntax, equals('/[id]'));
        expect('/<id>/item'.toBracketParameterSyntax, equals('/[id]/item'));
        expect('/top/<id>'.toBracketParameterSyntax, equals('/top/[id]'));
      });
    });

    group('hasDiamondParameter', () {
      test(
        'should return true if the route contains diamond parameters',
        () {
          expect('/<id>'.hasDiamondParameter, isTrue);
          expect('/<id>/item'.hasDiamondParameter, isTrue);
          expect('/top/<id>'.hasDiamondParameter, isTrue);
        },
      );

      test(
        'should return false if the route does not contain diamond parameters',
        () {
          expect('/id'.hasDiamondParameter, isFalse);
          expect('/id/item'.hasDiamondParameter, isFalse);
          expect('/<top/id'.hasDiamondParameter, isFalse);
          expect('/top>/id'.hasDiamondParameter, isFalse);
        },
      );
    });

    group('parameterNames', () {
      test('should return the parameter names', () {
        expect('/<id>'.parameterNames, equals(['id']));
        expect('/<id>/item'.parameterNames, equals(['id']));
        expect('/top/<id>'.parameterNames, equals(['id']));
        expect('/<id>/item/<name>'.parameterNames, equals(['id', 'name']));
        expect('/[id]'.parameterNames, equals(['id']));
        expect('/[id]/item'.parameterNames, equals(['id']));
        expect('/top/[id]'.parameterNames, equals(['id']));
        expect('/[id]/item/[name]'.parameterNames, equals(['id', 'name']));
      });
    });
  });
}

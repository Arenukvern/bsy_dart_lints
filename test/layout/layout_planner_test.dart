import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:bsy_dart_lints/src/layout/class_layout_snapshot.dart';
import 'package:bsy_dart_lints/src/layout/layout_planner.dart';
import 'package:bsy_dart_lints/src/layout/member_block.dart';
import 'package:test/test.dart';

void main() {
  group('LayoutPlanner', () {
    test('canonical reorder is deterministic', () {
      const original = '''
class A {
  final int other;

  static const tag = 'x';

  A(this.value);

  final int value;
}
''';

      final firstSnapshot = _snapshotFor(original);
      final firstOrder = LayoutPlanner.planCanonicalMemberOrder(firstSnapshot);
      expect(firstOrder, isNotNull);

      final firstEdit = LayoutPlanner.planClassBodyRewrite(
        firstSnapshot,
        firstOrder!,
      );
      final onceRewritten = _applyEdit(original, firstEdit);

      final secondSnapshot = _snapshotFor(onceRewritten);
      final secondOrder = LayoutPlanner.planCanonicalMemberOrder(
        secondSnapshot,
      );
      expect(secondOrder, isNull);

      expect(
        onceRewritten.indexOf("static const tag = 'x';") <
            onceRewritten.indexOf('final int value;'),
        isTrue,
      );
      expect(
        onceRewritten.indexOf('final int value;') <
            onceRewritten.indexOf('final int other;'),
        isTrue,
      );
    });

    test('static const reorder keeps methods before first field', () {
      const original = '''
class A {
  void helper() {}

  final int value;

  static const tag = 'x';

  A(this.value);
}
''';

      final snapshot = _snapshotFor(original);
      final order = LayoutPlanner.planStaticConstBeforeFieldsAndConstructors(
        snapshot,
      );
      expect(order, isNotNull);

      final rewritten = _applyEdit(
        original,
        LayoutPlanner.planClassBodyRewrite(snapshot, order!),
      );

      expect(
        rewritten.indexOf('void helper() {}') <
            rewritten.indexOf("static const tag = 'x';"),
        isTrue,
      );
      expect(
        rewritten.indexOf("static const tag = 'x';") <
            rewritten.indexOf('final int value;'),
        isTrue,
      );
    });

    test('normalizes missing blank line to exactly one', () {
      const original = '''
class A {
  final int first;
  final int second;

  A(this.first, this.second);
}
''';

      final snapshot = _snapshotFor(original);
      final first = _blockForField(snapshot, 'first');
      final second = _blockForField(snapshot, 'second');

      final edit = LayoutPlanner.planNormalizeExactSingleBlankLine(
        snapshot,
        first,
        second,
      );
      expect(edit, isNotNull);

      final rewritten = _applyEdit(original, edit!);
      expect(rewritten, contains('final int first;\n\n  final int second;'));
    });

    test('skips blank-line normalization when comments are in the gap', () {
      const original = '''
class A {
  final int first;
  // keep this note
  final int second;

  A(this.first, this.second);
}
''';

      final snapshot = _snapshotFor(original);
      final first = _blockForField(snapshot, 'first');
      final second = _blockForField(snapshot, 'second');

      final edit = LayoutPlanner.planNormalizeExactSingleBlankLine(
        snapshot,
        first,
        second,
      );
      expect(edit, isNull);
    });
  });
}

String _applyEdit(String content, PlannedTextEdit edit) {
  return content.replaceRange(
    edit.offset,
    edit.offset + edit.length,
    edit.replacement,
  );
}

MemberBlock _blockForField(ClassLayoutSnapshot snapshot, String name) {
  return snapshot.memberBlocks.firstWhere((block) {
    final field = block.field;
    if (field == null) {
      return false;
    }
    return field.fields.variables.any(
      (variable) => variable.name.lexeme == name,
    );
  });
}

ClassLayoutSnapshot _snapshotFor(String content) {
  final parseResult = parseString(content: content);
  final classNode = parseResult.unit.declarations
      .whereType<ClassDeclaration>()
      .first;
  return ClassLayoutSnapshot.fromClass(classNode, content);
}

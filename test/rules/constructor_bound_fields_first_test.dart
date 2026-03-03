// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:bsy_dart_lints/src/rules/constructor_bound_fields_first.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ConstructorBoundFieldsFirstRuleTest);
  });
}

@reflectiveTest
final class ConstructorBoundFieldsFirstRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = ConstructorBoundFieldsFirstRule();
    super.setUp();
  }

  Future<void> test_accepts_canonical_order() async {
    await assertNoDiagnostics(r'''
class A {
  static const tag = 'x';

  final String name;

  A(this.name);

  void helper() {}
}
''');
  }

  Future<void> test_reports_field_after_method() async {
    const content = r'''
class A {
  void helper() {}

  final String name;

  A(this.name);
}
''';

    await assertDiagnostics(content, [
      lint(content.indexOf('final String name;'), 'final String name;'.length),
    ]);
  }

  Future<void> test_reports_constructor_bound_field_after_other_field() async {
    const content = r'''
class A {
  final int other = 0;

  final int value;

  A(this.value);
}
''';

    await assertDiagnostics(content, [
      lint(content.indexOf('final int value;'), 'final int value;'.length),
    ]);
  }

  Future<void> test_accepts_constructor_initializer_fields() async {
    await assertNoDiagnostics(r'''
class A {
  final int first;

  final int second;

  A(int value)
      : first = value,
        second = value + 1;
}
''');
  }
}

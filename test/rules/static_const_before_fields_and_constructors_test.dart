// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:bsy_dart_lints/src/rules/static_const_before_fields_and_constructors.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(StaticConstBeforeFieldsAndConstructorsRuleTest);
  });
}

@reflectiveTest
final class StaticConstBeforeFieldsAndConstructorsRuleTest
    extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = StaticConstBeforeFieldsAndConstructorsRule();
    super.setUp();
  }

  Future<void> test_accepts_static_const_first() async {
    await assertNoDiagnostics(r'''
class A {
  static const tag = 'x';

  final int value;

  A(this.value);
}
''');
  }

  Future<void> test_reports_field_before_static_const() async {
    const content = r'''
class A {
  final int value;

  static const tag = 'x';

  A(this.value);
}
''';

    await assertDiagnostics(content, [
      lint(content.indexOf('final int value;'), 'final int value;'.length),
    ]);
  }

  Future<void> test_reports_constructor_before_static_const() async {
    const content = r'''
class A {
  A(this.value);

  static const tag = 'x';

  final int value;
}
''';

    await assertDiagnostics(content, [
      lint(content.indexOf('A(this.value);'), 'A(this.value);'.length),
    ]);
  }

  Future<void> test_allows_methods_before_static_const() async {
    await assertNoDiagnostics(r'''
class A {
  void helper() {}

  static const tag = 'x';

  final int value;

  A(this.value);
}
''');
  }
}

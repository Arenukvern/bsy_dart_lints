// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:bsy_dart_lints/src/rules/constructors_separated_from_ctor_bound_fields.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ConstructorsSeparatedFromCtorBoundFieldsRuleTest);
  });
}

@reflectiveTest
final class ConstructorsSeparatedFromCtorBoundFieldsRuleTest
    extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = ConstructorsSeparatedFromCtorBoundFieldsRule();
    super.setUp();
  }

  Future<void> test_accepts_exactly_one_blank_line() async {
    await assertNoDiagnostics(r'''
class A {
  final int value;

  A(this.value);
}
''');
  }

  Future<void> test_reports_missing_blank_line() async {
    const content = r'''
class A {
  final int value;
  A(this.value);
}
''';

    await assertDiagnostics(content, [
      lint(content.indexOf('A(this.value);'), 'A(this.value);'.length),
    ]);
  }

  Future<void> test_reports_too_many_blank_lines() async {
    const content = r'''
class A {
  final int value;


  A(this.value);
}
''';

    await assertDiagnostics(content, [
      lint(content.indexOf('A(this.value);'), 'A(this.value);'.length),
    ]);
  }

  Future<void> test_ignores_without_constructor_bound_fields() async {
    await assertNoDiagnostics(r'''
class A {
  int value = 0;

  A(int input);
}
''');
  }
}

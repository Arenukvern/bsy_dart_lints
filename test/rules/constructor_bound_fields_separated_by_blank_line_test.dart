// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:bsy_dart_lints/src/rules/constructor_bound_fields_separated_by_blank_line.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ConstructorBoundFieldsSeparatedByBlankLineRuleTest);
  });
}

@reflectiveTest
final class ConstructorBoundFieldsSeparatedByBlankLineRuleTest
    extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = ConstructorBoundFieldsSeparatedByBlankLineRule();
    super.setUp();
  }

  Future<void> test_accepts_exactly_one_blank_line() async {
    await assertNoDiagnostics(r'''
class A {
  final int first;

  final int second;

  A(this.first, this.second);
}
''');
  }

  Future<void> test_reports_missing_blank_line() async {
    const content = r'''
class A {
  final int first;
  final int second;

  A(this.first, this.second);
}
''';

    await assertDiagnostics(content, [
      lint(content.indexOf('final int second;'), 'final int second;'.length),
    ]);
  }

  Future<void> test_reports_too_many_blank_lines() async {
    const content = r'''
class A {
  final int first;


  final int second;

  A(this.first, this.second);
}
''';

    await assertDiagnostics(content, [
      lint(content.indexOf('final int second;'), 'final int second;'.length),
    ]);
  }

  Future<void> test_ignores_non_adjacent_constructor_bound_fields() async {
    await assertNoDiagnostics(r'''
class A {
  final int first;

  void helper() {}

  final int second;

  A(this.first, this.second);
}
''');
  }
}

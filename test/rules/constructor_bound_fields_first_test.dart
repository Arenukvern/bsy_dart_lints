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

  Future<void> test_accepts_canonical_layout_with_blanks() async {
    await assertNoDiagnostics(r'''
class A {
  static const version = '1.0.0';

  final String name;

  final int age;

  final Object _secret;

  A(this.name, this.age, this._secret);

  String tag = 'demo';

  bool get isAdult => age >= 18;

  String describe() => '$name:$age:$tag:$version:$_secret';
}
''');
  }

  Future<void> test_reports_ctor_bound_field_before_constructor() async {
    const content = r'''
class A {
  void helper() {}

  final String name;

  A(this.name);
}
''';

    await assertDiagnostics(content, [
      lint(content.indexOf('void helper() {}'), 'void helper() {}'.length),
      lint(content.indexOf('final String name;'), 'final String name;'.length),
      lint(content.indexOf('A(this.name);'), 'A(this.name);'.length),
    ]);
  }

  Future<void> test_reports_blank_lines_in_class_layout() async {
    const content = r'''
class A {
  static const tag = 'x';
  final int first;
  final int second;
  A(this.first, this.second);
}
''';

    await assertDiagnostics(content, [
      lint(content.indexOf('final int first;'), 'final int first;'.length),
      lint(content.indexOf('final int second;'), 'final int second;'.length),
      lint(content.indexOf('A(this.first, this.second);'),
          'A(this.first, this.second);'.length),
    ]);
  }

  Future<void> test_reports_getter_before_method() async {
    const content = r'''
class A {
  final int value;

  A(this.value);

  void render() {}

  int get length => value;
}
''';

    await assertDiagnostics(content, [
      lint(content.indexOf('void render() {}'), 'void render() {}'.length),
      lint(content.indexOf('int get length => value;'), 'int get length => value;'.length),
    ]);
  }
}

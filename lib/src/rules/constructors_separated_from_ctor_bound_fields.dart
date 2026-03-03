import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:bsy_dart_lints/src/layout/class_layout_snapshot.dart';

final class ConstructorsSeparatedFromCtorBoundFieldsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'constructors_separated_from_ctor_bound_fields',
    'Constructors must be separated from constructor-bound fields by exactly one blank line.',
    correctionMessage:
        'Try leaving one empty line between constructor-bound fields and constructors.',
    uniqueName: 'bsy_dart_lints.constructors_separated_from_ctor_bound_fields',
  );

  ConstructorsSeparatedFromCtorBoundFieldsRule()
    : super(
        name: 'constructors_separated_from_ctor_bound_fields',
        description:
            'Require exactly one blank line between the constructor-bound field section and constructors.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addClassDeclaration(this, _Visitor(this, context));
  }
}

final class _Visitor extends SimpleAstVisitor<void> {
  final ConstructorsSeparatedFromCtorBoundFieldsRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final unit = context.currentUnit;
    if (unit == null) {
      return;
    }

    final snapshot = ClassLayoutSnapshot.fromClass(node, unit.content);
    final boundFields = snapshot.constructorBoundFieldBlocks;
    if (boundFields.isEmpty) {
      return;
    }

    final lastBoundField = boundFields.last;
    final firstConstructor = snapshot.firstGenerativeConstructorAfter(
      lastBoundField,
    );
    if (firstConstructor == null) {
      return;
    }
    if (firstConstructor.index != lastBoundField.index + 1) {
      return;
    }

    if (snapshot.blankLinesBetween(lastBoundField, firstConstructor) != 1) {
      rule.reportAtNode(firstConstructor.member);
    }
  }
}

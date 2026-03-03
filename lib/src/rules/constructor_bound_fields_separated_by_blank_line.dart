import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:bsy_dart_lints/src/layout/class_layout_snapshot.dart';

final class ConstructorBoundFieldsSeparatedByBlankLineRule
    extends AnalysisRule {
  static const LintCode code = LintCode(
    'constructor_bound_fields_separated_by_blank_line',
    'Constructor-bound fields must be separated by exactly one blank line.',
    correctionMessage:
        'Try leaving one empty line between consecutive constructor-bound fields.',
    uniqueName:
        'bsy_dart_lints.constructor_bound_fields_separated_by_blank_line',
  );

  ConstructorBoundFieldsSeparatedByBlankLineRule()
    : super(
        name: 'constructor_bound_fields_separated_by_blank_line',
        description:
            'Require exactly one blank line between adjacent constructor-bound field declarations.',
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
  final ConstructorBoundFieldsSeparatedByBlankLineRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final unit = context.currentUnit;
    if (unit == null) {
      return;
    }

    final snapshot = ClassLayoutSnapshot.fromClass(node, unit.content);
    final blocks = snapshot.constructorBoundFieldBlocks;
    if (blocks.length < 2) {
      return;
    }

    for (var i = 1; i < blocks.length; i++) {
      final previous = blocks[i - 1];
      final current = blocks[i];
      if (previous.index + 1 != current.index) {
        continue;
      }
      if (snapshot.blankLinesBetween(previous, current) != 1) {
        rule.reportAtNode(current.member);
      }
    }
  }
}

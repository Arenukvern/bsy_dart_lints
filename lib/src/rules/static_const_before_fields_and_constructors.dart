import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:bsy_dart_lints/src/layout/class_layout_snapshot.dart';

final class StaticConstBeforeFieldsAndConstructorsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'static_const_before_fields_and_constructors',
    'Static const members must be declared before fields and constructors.',
    correctionMessage:
        'Try moving static const members above all fields and constructors.',
    uniqueName: 'bsy_dart_lints.static_const_before_fields_and_constructors',
  );

  StaticConstBeforeFieldsAndConstructorsRule()
    : super(
        name: 'static_const_before_fields_and_constructors',
        description:
            'Require static const members to be declared before any field or constructor.',
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
  final StaticConstBeforeFieldsAndConstructorsRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final unit = context.currentUnit;
    if (unit == null) {
      return;
    }

    final snapshot = ClassLayoutSnapshot.fromClass(node, unit.content);
    final staticConstBlocks = snapshot.staticConstBlocks;
    if (staticConstBlocks.isEmpty) {
      return;
    }

    final firstStaticConstIndex = staticConstBlocks.first.index;
    for (final block in snapshot.memberBlocks) {
      if (block.index >= firstStaticConstIndex) {
        break;
      }

      final isFieldViolation = block.isField && !block.isStaticConstField;
      final isConstructorViolation = block.isConstructor;
      if (isFieldViolation || isConstructorViolation) {
        rule.reportAtNode(block.member);
      }
    }
  }
}

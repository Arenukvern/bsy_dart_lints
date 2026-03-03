import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:bsy_dart_lints/src/layout/class_layout_snapshot.dart';
import 'package:bsy_dart_lints/src/layout/layout_planner.dart';

final class ConstructorBoundFieldsFirstRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'constructor_bound_fields_first',
    'Constructor-bound fields must be at the beginning of the class body.',
    correctionMessage:
        'Try placing static const members first and constructor-bound fields right after them.',
    uniqueName: 'bsy_dart_lints.constructor_bound_fields_first',
  );

  ConstructorBoundFieldsFirstRule()
    : super(
        name: 'constructor_bound_fields_first',
        description:
            'Require constructor-bound fields to appear at the beginning of class members.',
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
  final ConstructorBoundFieldsFirstRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final unit = context.currentUnit;
    if (unit == null) {
      return;
    }

    final snapshot = ClassLayoutSnapshot.fromClass(node, unit.content);
    if (snapshot.constructorBoundFieldBlocks.isEmpty) {
      return;
    }

    var maxCategory = -1;
    for (final block in snapshot.memberBlocks) {
      final category = LayoutPlanner.canonicalCategory(snapshot, block);
      if ((category == 0 || category == 1) && category < maxCategory) {
        rule.reportAtNode(block.member);
      }
      if (category > maxCategory) {
        maxCategory = category;
      }
    }
  }
}

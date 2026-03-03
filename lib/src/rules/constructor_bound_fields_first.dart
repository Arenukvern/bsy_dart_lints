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
    'Class members are not in the canonical layout.',
    correctionMessage:
        'Reorder class members as static const fields, constructor-bound fields, '
        'constructors, then all remaining members; keep one blank line between '
        'all adjacent members.',
    uniqueName: 'bsy_dart_lints.constructor_bound_fields_first',
  );

  ConstructorBoundFieldsFirstRule()
    : super(
        name: 'constructor_bound_fields_first',
        description:
            'Enforce canonical member order plus one-blank-line spacing between '
            'adjacent members.',
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
    try {
      final unit = context.currentUnit;
      if (unit == null) {
        return;
      }

      final snapshot = ClassLayoutSnapshot.fromClass(node, unit.content);
      final ordered = LayoutPlanner.planCanonicalMemberOrder(snapshot);
      if (ordered == null) {
        return;
      }

      final expectedPositions = <int, int>{};
      for (var i = 0; i < ordered.length; i++) {
        expectedPositions[ordered[i].index] = i;
      }

      final diagnostics = <int>{};
      for (final block in snapshot.memberBlocks) {
        if (expectedPositions[block.index] != block.index) {
          diagnostics.add(block.member.offset);
        }
      }

      if (ordered.length >= 2) {
        for (var i = 0; i < ordered.length - 1; i++) {
          final first = ordered[i];
          final second = ordered[i + 1];
          if (second.start < first.end) {
            continue;
          }
          if (LayoutPlanner.planNormalizeExactSingleBlankLine(
                snapshot,
                first,
                second,
              ) !=
              null) {
            diagnostics.add(second.member.offset);
          }
        }
      }

      for (final offset in diagnostics) {
        final block = snapshot.blockContainingOffset(offset);
        if (block != null) {
          rule.reportAtNode(block.member);
        }
      }
    } on Object {
      return;
    }
  }
}

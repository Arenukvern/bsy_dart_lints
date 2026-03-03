import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:bsy_dart_lints/src/layout/class_layout_snapshot.dart';
import 'package:bsy_dart_lints/src/layout/layout_planner.dart';

final class ReorderClassMembersFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'bsy_dart_lints.fix.reorder_class_members',
    DartFixKindPriority.standard,
    'Reorder class members',
  );

  ReorderClassMembersFix({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.acrossSingleFile;

  @override
  FixKind? get multiFixKind => _fixKind;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final classNode = _classDeclarationFor(node);
    if (classNode == null) {
      return;
    }

    final snapshot = ClassLayoutSnapshot.fromClass(
      classNode,
      unitResult.content,
    );
    final orderedMembers = LayoutPlanner.planCanonicalMemberOrder(snapshot);
    if (orderedMembers == null) {
      return;
    }

    final edit = LayoutPlanner.planClassBodyRewrite(snapshot, orderedMembers);
    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(edit.offset, edit.length),
        edit.replacement,
      );
    });
  }
}

ClassDeclaration? _classDeclarationFor(AstNode? node) {
  return node?.thisOrAncestorOfType<ClassDeclaration>();
}

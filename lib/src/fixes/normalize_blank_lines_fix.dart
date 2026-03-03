import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:bsy_dart_lints/src/layout/class_layout_snapshot.dart';
import 'package:bsy_dart_lints/src/layout/layout_planner.dart';

final class NormalizeCtorBoundFieldSeparationFix
    extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'bsy_dart_lints.fix.normalize_ctor_bound_field_separation',
    DartFixKindPriority.standard,
    'Normalize blank lines between constructor-bound fields',
  );

  NormalizeCtorBoundFieldSeparationFix({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final classNode = node.thisOrAncestorOfType<ClassDeclaration>();
    if (classNode == null) {
      return;
    }

    final offset = diagnosticOffset;
    if (offset == null) {
      return;
    }

    final snapshot = ClassLayoutSnapshot.fromClass(
      classNode,
      unitResult.content,
    );
    final target = snapshot.blockContainingOffset(offset);
    if (target == null || !snapshot.isConstructorBoundFieldBlock(target)) {
      return;
    }

    final previous = snapshot.previousConstructorBoundFieldBlock(target);
    if (previous == null || previous.index + 1 != target.index) {
      return;
    }

    final edit = LayoutPlanner.planNormalizeExactSingleBlankLine(
      snapshot,
      previous,
      target,
    );
    if (edit == null) {
      return;
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(edit.offset, edit.length),
        edit.replacement,
      );
    });
  }
}

final class NormalizeCtorSectionSeparationFix
    extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'bsy_dart_lints.fix.normalize_ctor_section_separation',
    DartFixKindPriority.standard,
    'Normalize blank lines between constructor-bound fields and constructor',
  );

  NormalizeCtorSectionSeparationFix({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final classNode = node.thisOrAncestorOfType<ClassDeclaration>();
    if (classNode == null) {
      return;
    }

    final offset = diagnosticOffset;
    if (offset == null) {
      return;
    }

    final snapshot = ClassLayoutSnapshot.fromClass(
      classNode,
      unitResult.content,
    );
    final constructorBlock = snapshot.blockContainingOffset(offset);
    if (constructorBlock == null || !constructorBlock.isGenerativeConstructor) {
      return;
    }
    if (constructorBlock.index == 0) {
      return;
    }

    final previous = snapshot.memberBlocks[constructorBlock.index - 1];
    if (!snapshot.isConstructorBoundFieldBlock(previous)) {
      return;
    }

    final edit = LayoutPlanner.planNormalizeExactSingleBlankLine(
      snapshot,
      previous,
      constructorBlock,
    );
    if (edit == null) {
      return;
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(edit.offset, edit.length),
        edit.replacement,
      );
    });
  }
}

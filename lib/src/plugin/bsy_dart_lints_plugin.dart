import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:bsy_dart_lints/src/fixes/normalize_blank_lines_fix.dart';
import 'package:bsy_dart_lints/src/fixes/reorder_class_members_fix.dart';
import 'package:bsy_dart_lints/src/rules/constructor_bound_fields_first.dart';
import 'package:bsy_dart_lints/src/rules/constructor_bound_fields_separated_by_blank_line.dart';
import 'package:bsy_dart_lints/src/rules/constructors_separated_from_ctor_bound_fields.dart';
import 'package:bsy_dart_lints/src/rules/static_const_before_fields_and_constructors.dart';

final class BsyDartLintsPlugin extends Plugin {
  @override
  String get name => 'bsy_dart_lints';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(ConstructorBoundFieldsFirstRule());
    registry.registerLintRule(ConstructorBoundFieldsSeparatedByBlankLineRule());
    registry.registerLintRule(ConstructorsSeparatedFromCtorBoundFieldsRule());
    registry.registerLintRule(StaticConstBeforeFieldsAndConstructorsRule());

    registry.registerFixForRule(
      ConstructorBoundFieldsFirstRule.code,
      ReorderClassMembersFix.new,
    );
    registry.registerFixForRule(
      ConstructorBoundFieldsSeparatedByBlankLineRule.code,
      NormalizeCtorBoundFieldSeparationFix.new,
    );
    registry.registerFixForRule(
      ConstructorsSeparatedFromCtorBoundFieldsRule.code,
      NormalizeCtorSectionSeparationFix.new,
    );
    registry.registerFixForRule(
      StaticConstBeforeFieldsAndConstructorsRule.code,
      MoveStaticConstBeforeFieldsAndConstructorsFix.new,
    );
  }
}

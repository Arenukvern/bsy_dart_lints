import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:bsy_dart_lints/src/fixes/reorder_class_members_fix.dart';
import 'package:bsy_dart_lints/src/rules/constructor_bound_fields_first.dart';

final class BsyDartLintsPlugin extends Plugin {
  @override
  String get name => 'bsy_dart_lints';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(ConstructorBoundFieldsFirstRule());

    registry.registerFixForRule(
      ConstructorBoundFieldsFirstRule.code,
      ReorderClassMembersFix.new,
    );
  }
}

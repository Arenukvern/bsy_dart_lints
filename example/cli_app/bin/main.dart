import 'package:bsy_dart_lints_cli_example/all_rules_violations.dart';
import 'package:bsy_dart_lints_cli_example/bad_layout.dart';
import 'package:bsy_dart_lints_cli_example/good_layout.dart';

void main() {
  final good = GoodLayout('alice', 30, Object());
  final bad = BadLayout('bob', 29, Object());
  final allRules = AllRulesViolations('carol', 31, Object());

  print('Good: ${good.describe()}');
  print('Bad: ${bad.describe()}');
  print('AllRulesViolations: ${allRules.describe()}');
}

import 'package:bsy_dart_lints_cli_example/bad_layout.dart';
import 'package:bsy_dart_lints_cli_example/good_layout.dart';

void main() {
  final good = GoodLayout('alice', 30);
  final bad = BadLayout('bob', 29);

  print('Good: ${good.describe()}');
  print('Bad: ${bad.describe()}');
}

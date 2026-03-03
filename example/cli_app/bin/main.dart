import 'package:bsy_dart_lints_cli_example/bad_layout.dart';

void main() {
  final good = GoodLayout('alice', 30);
  final bad = BadLayout('bob', 29);

  print('Good: ${good.describe()}');
  print('Bad: ${bad.describe()}');
}

class GoodLayout {
  GoodLayout(this.name, this.age);
  final String name;
  final int age;
  static const version = '1.0.0';

  String describe() {
    return 'GoodLayout: $name, $age';
  }
}

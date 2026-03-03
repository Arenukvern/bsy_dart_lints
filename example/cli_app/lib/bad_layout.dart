class BadLayout {
  final String name;
  final int age;
  final Object _secret;
  BadLayout(this.name, this.age, this._secret);
  bool get isGood => true;
  static const version = '1.0.0';
  String version2 = '1.0.0';

  String describe() => 'BadLayout: $name, $age, $_secret';
}

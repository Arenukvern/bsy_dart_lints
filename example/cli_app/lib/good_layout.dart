class GoodLayout {
  static const version = '1.0.0';

  final String name;

  final Object _secret;

  final int age;

  GoodLayout(this.name, this.age, this._secret);

  var version2 = '1.0.0';

  String version3 = '1.0.0';

  bool get isGood => true;

  String describe() => '$name:$age@$version:$version2:$version3:$_secret';
}

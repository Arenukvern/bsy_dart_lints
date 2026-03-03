class GoodLayout {
  static const version = '1.0.0';

  final String name;

  final int age;

  GoodLayout(this.name, this.age);

  String describe() => '$name:$age@$version';
}

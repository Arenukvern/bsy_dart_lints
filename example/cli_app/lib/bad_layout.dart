class BadLayout {
  final String other = 'other';

  static const version = '1.0.0';

  void helper() {}

  final String name;
  final int age;
  BadLayout(this.name, this.age);

  String describe() => '$name:$age:$other';
}

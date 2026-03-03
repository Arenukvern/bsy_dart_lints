class AllRulesViolations {
  final String name;
  bool get isAdult => age >= 18;
  String tag = 'demo';
  static const version = '1.0.0';
  AllRulesViolations(this.name, this.age, this._secret);

  final int age;
  String describe() => '$name:$age:$tag:$version:$_secret';
  final Object _secret;
}

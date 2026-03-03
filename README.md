# bsy_dart_lints

`bsy_dart_lints` is a Dart analyzer plugin package that enforces a single class member
layout rule and provides a single autofix.

## Included rules

- `constructor_bound_fields_first`

## Install and enable

Add the plugin in your project's top-level `analysis_options.yaml`.

### Local path (during development)

```yaml
plugins:
  bsy_dart_lints:
    path: /absolute/path/to/bsy_dart_lints
    diagnostics:
      constructor_bound_fields_first: true
```

### Published version

```yaml
plugins:
  bsy_dart_lints:
    version: ^1.1.0
    diagnostics:
      constructor_bound_fields_first: true
```

## Ignore syntax

```dart
// ignore: bsy_dart_lints/constructor_bound_fields_first
```

## Canonical style

```dart
class D {
  static const v = '';

  final field1;

  final field2;

  D(this.field1, this.field2);

  String describe() => '$field1$field2';
}
```

## Quick fixes

- Reorder class members into canonical layout (static const members, constructor-bound fields, constructors, then remaining members) and normalize spacing to one blank line between adjacent members.

## Example CLI app

Use the sample app in `example/cli_app` for manual validation:

```bash
cd example/cli_app
dart pub get
dart run bin/main.dart
dart analyze
```

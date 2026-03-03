# bsy_dart_lints

`bsy_dart_lints` is a Dart analyzer plugin package that enforces class member
layout rules and provides quick fixes.

## Included rules

- `constructor_bound_fields_first`
- `constructor_bound_fields_separated_by_blank_line`
- `constructors_separated_from_ctor_bound_fields`
- `static_const_before_fields_and_constructors`

## Install and enable

Add the plugin in your project's top-level `analysis_options.yaml`.

### Local path (during development)

```yaml
plugins:
  bsy_dart_lints:
    path: /absolute/path/to/bsy_dart_lints
    diagnostics:
      constructor_bound_fields_first: true
      constructor_bound_fields_separated_by_blank_line: true
      constructors_separated_from_ctor_bound_fields: true
      static_const_before_fields_and_constructors: true
```

### Published version

```yaml
plugins:
  bsy_dart_lints:
    version: ^1.0.0
    diagnostics:
      constructor_bound_fields_first: true
      constructor_bound_fields_separated_by_blank_line: true
      constructors_separated_from_ctor_bound_fields: true
      static_const_before_fields_and_constructors: true
```

## Ignore syntax

```dart
// ignore: bsy_dart_lints/constructor_bound_fields_first
```

## Enforced style example

```dart
class D {
  static const v = '';

  final field1;

  final field2;

  D(this.field1, this.field2);
}
```

## Quick fixes

- Reorder class members for canonical layout.
- Move `static const` members before fields and constructors.
- Normalize blank lines between constructor-bound fields.
- Normalize blank lines between constructor-bound fields and constructors.

## Example CLI app

Use the sample app in `example/cli_app` for manual validation:

```bash
cd example/cli_app
dart pub get
dart run bin/main.dart
dart analyze
```

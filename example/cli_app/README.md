# bsy_dart_lints CLI example

This example is a small Dart CLI package used to validate plugin behavior.

## Run

```bash
cd example/cli_app
dart pub get
dart run bin/main.dart
```

## Analyze with plugin

```bash
cd example/cli_app
dart analyze
```

`analysis_options.yaml` enables all `bsy_dart_lints` rules and points to the
local plugin package via `path: ../../`.

Files:
- `lib/good_layout.dart` follows all rules.
- `lib/bad_layout.dart` intentionally violates several rules.
- `lib/all_rules_violations.dart` intentionally violates all plugin rules in one class.

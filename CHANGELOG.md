## 1.1.0

- Replace all previous class-layout lint rules with a single
  `constructor_bound_fields_first` rule.
- `constructor_bound_fields_first` enforces canonical ordering
  (`static const` → constructor-bound fields → constructors → other members),
  getter-before-method ordering for remaining members, and one-blank-line spacing
  between adjacent members.
- Preserve one-shot autofix in `ReorderClassMembersFix` for both ordering and spacing normalization.

## 1.0.2

- Add `getters_before_methods`.
- Add `non_constructor_members_after_constructors`.

## 1.0.1

- Fix canonical class-member reordering so constructors are placed after
  constructor-bound fields and before other members.
- Add `members_after_constructor_separated_by_blank_line` lint with an automatic
  blank-line normalization fix.

## 1.0.0

- Initial version.

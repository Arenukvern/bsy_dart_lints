import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';

final class MemberBlock {
  final ClassMember member;
  final int index;
  final int start;
  final int end;
  final bool hasAmbiguousLeadingTrivia;

  const MemberBlock({
    required this.member,
    required this.index,
    required this.start,
    required this.end,
    required this.hasAmbiguousLeadingTrivia,
  });

  ConstructorDeclaration? get constructor => member is ConstructorDeclaration
      ? member as ConstructorDeclaration
      : null;

  FieldDeclaration? get field =>
      member is FieldDeclaration ? member as FieldDeclaration : null;

  bool get isConstructor => constructor != null;

  bool get isField => field != null;

  bool get isGenerativeConstructor {
    final value = constructor;
    if (value == null) {
      return false;
    }
    return value.factoryKeyword == null && value.redirectedConstructor == null;
  }

  bool get isInstanceField {
    final value = field;
    return value != null && !value.isStatic;
  }

  bool get isStaticConstField {
    final value = field;
    return value != null && value.isStatic && value.fields.isConst;
  }

  bool get hasMultipleVariables {
    final value = field;
    return value != null && value.fields.variables.length > 1;
  }

  SourceRange get sourceRange => SourceRange(start, end - start);
}

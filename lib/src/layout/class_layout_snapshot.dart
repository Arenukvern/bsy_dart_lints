import 'dart:math' as math;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:bsy_dart_lints/src/layout/member_block.dart';

final class ClassLayoutSnapshot {
  final ClassDeclaration classNode;
  final String content;
  final LineInfo lineInfo;
  final List<MemberBlock> memberBlocks;
  final Set<String> constructorBoundFieldNames;
  final Set<int> _constructorBoundFieldIndexes;
  final bool hasUnsafeCtorBoundMultiVariableField;
  final bool hasAmbiguousTriviaOutsideMembers;

  ClassLayoutSnapshot._({
    required this.classNode,
    required this.content,
    required this.lineInfo,
    required this.memberBlocks,
    required this.constructorBoundFieldNames,
    required Set<int> constructorBoundFieldIndexes,
    required this.hasUnsafeCtorBoundMultiVariableField,
    required this.hasAmbiguousTriviaOutsideMembers,
  }) : _constructorBoundFieldIndexes = constructorBoundFieldIndexes;

  factory ClassLayoutSnapshot.fromClass(
    ClassDeclaration classNode,
    String content,
  ) {
    final memberBlocks = _buildMemberBlocks(classNode, content);
    final constructorBoundFieldNames = _collectConstructorBoundFieldNames(
      classNode,
    );

    final constructorBoundFieldIndexes = <int>{};
    var hasUnsafeCtorBoundMultiVariableField = false;
    for (final block in memberBlocks) {
      if (!block.isInstanceField) {
        continue;
      }

      final field = block.field!;
      final variableNames = field.fields.variables
          .map((variable) => variable.name.lexeme)
          .toSet();
      final isConstructorBound = variableNames.any(
        constructorBoundFieldNames.contains,
      );
      if (!isConstructorBound) {
        continue;
      }

      constructorBoundFieldIndexes.add(block.index);
      if (field.fields.variables.length > 1) {
        hasUnsafeCtorBoundMultiVariableField = true;
      }
    }

    final lineInfo = (classNode.root as CompilationUnit).lineInfo;
    final hasAmbiguousTriviaOutsideMembers = _hasAmbiguousTriviaOutsideMembers(
      classNode,
      memberBlocks,
      content,
    );

    return ClassLayoutSnapshot._(
      classNode: classNode,
      content: content,
      lineInfo: lineInfo,
      memberBlocks: memberBlocks,
      constructorBoundFieldNames: constructorBoundFieldNames,
      constructorBoundFieldIndexes: constructorBoundFieldIndexes,
      hasUnsafeCtorBoundMultiVariableField:
          hasUnsafeCtorBoundMultiVariableField,
      hasAmbiguousTriviaOutsideMembers: hasAmbiguousTriviaOutsideMembers,
    );
  }

  List<MemberBlock> get constructorBoundFieldBlocks => memberBlocks
      .where((block) => isConstructorBoundFieldBlock(block))
      .toList(growable: false);

  List<MemberBlock> get generativeConstructorBlocks => memberBlocks
      .where((block) => block.isGenerativeConstructor)
      .toList(growable: false);

  List<MemberBlock> get staticConstBlocks => memberBlocks
      .where((block) => block.isStaticConstField)
      .toList(growable: false);

  bool isConstructorBoundFieldBlock(MemberBlock block) {
    return _constructorBoundFieldIndexes.contains(block.index);
  }

  MemberBlock? blockContainingOffset(int offset) {
    for (final block in memberBlocks) {
      if (offset >= block.start && offset <= block.end) {
        return block;
      }
    }
    return null;
  }

  MemberBlock? previousConstructorBoundFieldBlock(MemberBlock block) {
    for (var i = block.index - 1; i >= 0; i--) {
      final candidate = memberBlocks[i];
      if (isConstructorBoundFieldBlock(candidate)) {
        return candidate;
      }
      if (candidate.isField || candidate.isConstructor) {
        return null;
      }
    }
    return null;
  }

  MemberBlock? firstGenerativeConstructorAfter(MemberBlock block) {
    for (var i = block.index + 1; i < memberBlocks.length; i++) {
      final candidate = memberBlocks[i];
      if (candidate.isGenerativeConstructor) {
        return candidate;
      }
    }
    return null;
  }

  int blankLinesBetween(MemberBlock first, MemberBlock second) {
    final firstEndOffset = first.end == 0 ? 0 : first.end - 1;
    final firstEndLine = lineInfo.getLocation(firstEndOffset).lineNumber;
    final secondStartLine = lineInfo.getLocation(second.start).lineNumber;
    return secondStartLine - firstEndLine - 1;
  }

  String gapTextBetween(MemberBlock first, MemberBlock second) {
    return content.substring(first.end, second.start);
  }

  String indentationBefore(int offset) {
    final searchStart = offset <= 0 ? 0 : offset - 1;
    final lineStartOffset = content.lastIndexOf('\n', searchStart);
    final start = lineStartOffset == -1 ? 0 : lineStartOffset + 1;
    return content.substring(start, offset);
  }

  static Set<String> _collectConstructorBoundFieldNames(
    ClassDeclaration classNode,
  ) {
    final body = classNode.body as BlockClassBody;
    final names = <String>{};

    for (final member in body.members) {
      if (member is! ConstructorDeclaration) {
        continue;
      }
      if (member.factoryKeyword != null ||
          member.redirectedConstructor != null) {
        continue;
      }

      for (final parameter in member.parameters.parameters) {
        final normalized = _unwrapParameter(parameter);
        if (normalized is FieldFormalParameter) {
          names.add(normalized.name.lexeme);
        }
      }

      for (final initializer in member.initializers) {
        if (initializer is ConstructorFieldInitializer) {
          names.add(initializer.fieldName.name);
        }
      }
    }

    return names;
  }

  static FormalParameter _unwrapParameter(FormalParameter parameter) {
    var current = parameter;
    while (current is DefaultFormalParameter) {
      current = current.parameter;
    }
    return current;
  }

  static List<MemberBlock> _buildMemberBlocks(
    ClassDeclaration classNode,
    String content,
  ) {
    final body = classNode.body as BlockClassBody;
    final blocks = <MemberBlock>[];
    var previousEnd = body.leftBracket.end;

    for (var i = 0; i < body.members.length; i++) {
      final member = body.members[i];
      var start = member.offset;
      if (member.documentationComment case final comment?) {
        start = math.min(start, comment.offset);
      }
      if (member.metadata.isNotEmpty) {
        start = math.min(start, member.metadata.first.offset);
      }

      final gap = content.substring(previousEnd, start);
      final hasAmbiguousLeadingTrivia = _containsComment(gap);

      blocks.add(
        MemberBlock(
          member: member,
          index: i,
          start: start,
          end: member.end,
          hasAmbiguousLeadingTrivia: hasAmbiguousLeadingTrivia,
        ),
      );

      previousEnd = member.end;
    }

    return blocks;
  }

  static bool _hasAmbiguousTriviaOutsideMembers(
    ClassDeclaration classNode,
    List<MemberBlock> blocks,
    String content,
  ) {
    final body = classNode.body as BlockClassBody;
    final bodyStart = body.leftBracket.end;
    final bodyEnd = body.rightBracket.offset;
    if (blocks.isEmpty) {
      return _containsComment(content.substring(bodyStart, bodyEnd));
    }

    for (final block in blocks) {
      if (block.hasAmbiguousLeadingTrivia) {
        return true;
      }
    }

    final trailingTrivia = content.substring(blocks.last.end, bodyEnd);
    return _containsComment(trailingTrivia);
  }

  static bool _containsComment(String text) {
    return text.contains('//') || text.contains('/*');
  }
}

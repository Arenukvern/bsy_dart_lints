import 'package:analyzer/dart/ast/ast.dart';
import 'package:bsy_dart_lints/src/layout/class_layout_snapshot.dart';
import 'package:bsy_dart_lints/src/layout/member_block.dart';

final class LayoutPlanner {
  static int canonicalCategory(
    ClassLayoutSnapshot snapshot,
    MemberBlock block,
  ) {
    if (block.isStaticConstField) {
      return 0;
    }
    if (snapshot.isConstructorBoundFieldBlock(block)) {
      return 1;
    }
    if (block.isConstructor) {
      return 2;
    }
    return 3 + _nonConstructorMemberCategory(block.member);
  }

  static bool canSafelyReorder(
    ClassLayoutSnapshot snapshot, {
    bool requireSafeCtorBoundFields = true,
  }) {
    if (snapshot.memberBlocks.isEmpty) {
      return false;
    }
    if (snapshot.hasAmbiguousTriviaOutsideMembers) {
      return false;
    }
    if (requireSafeCtorBoundFields &&
        snapshot.hasUnsafeCtorBoundMultiVariableField) {
      return false;
    }
    return true;
  }

  static List<MemberBlock>? planCanonicalMemberOrder(
    ClassLayoutSnapshot snapshot,
  ) {
    if (!canSafelyReorder(snapshot)) {
      return null;
    }

    final ordered = _canonicalMemberOrder(snapshot);
    if (_isSameOrder(snapshot.memberBlocks, ordered) &&
        _hasRequiredSingleBlankLines(snapshot, ordered)) {
      return null;
    }
    return ordered;
  }

  static PlannedTextEdit planClassBodyRewrite(
    ClassLayoutSnapshot snapshot,
    List<MemberBlock> orderedBlocks,
  ) {
    final body = snapshot.classNode.body as BlockClassBody;
    final bodyStart = body.leftBracket.end;
    final bodyEnd = body.rightBracket.offset;
    final newLine = _newline(snapshot.content);
    final memberIndentation = _classMemberIndentation(snapshot);

    final rewrittenBody = StringBuffer();
    rewrittenBody.write(newLine);
    for (var i = 0; i < orderedBlocks.length; i++) {
      final block = orderedBlocks[i];
      rewrittenBody.write(memberIndentation);
      rewrittenBody.write(snapshot.content.substring(block.start, block.end));
      if (i != orderedBlocks.length - 1) {
        rewrittenBody
          ..write(newLine)
          ..write(newLine);
      }
    }
    rewrittenBody.write(newLine);

    return PlannedTextEdit(
      offset: bodyStart,
      length: bodyEnd - bodyStart,
      replacement: rewrittenBody.toString(),
    );
  }

  static PlannedTextEdit? planNormalizeExactSingleBlankLine(
    ClassLayoutSnapshot snapshot,
    MemberBlock first,
    MemberBlock second,
  ) {
    if (second.start < first.end) {
      return null;
    }

    final gapText = snapshot.gapTextBetween(first, second);
    if (gapText.contains('//') || gapText.contains('/*')) {
      return null;
    }

    final newLine = _newline(snapshot.content);
    final indentation = snapshot.indentationBefore(second.start);
    final normalizedIndentation = indentation.isEmpty
        ? _classMemberIndentation(snapshot)
        : indentation;
    final replacement = '$newLine$newLine$normalizedIndentation';
    if (gapText == replacement) {
      return null;
    }

    return PlannedTextEdit(
      offset: first.end,
      length: second.start - first.end,
      replacement: replacement,
    );
  }

  static List<MemberBlock> _canonicalMemberOrder(ClassLayoutSnapshot snapshot) {
    final staticConstBlocks = <MemberBlock>[];
    final constructorBoundBlocks = <MemberBlock>[];
    final constructorBlocks = <MemberBlock>[];
    final nonConstructorOtherBlocks = <MemberBlock>[];
    final getterBlocks = <MemberBlock>[];
    final methodBlocks = <MemberBlock>[];

    for (final block in snapshot.memberBlocks) {
      switch (canonicalCategory(snapshot, block)) {
        case 0:
          staticConstBlocks.add(block);
          break;
        case 1:
          constructorBoundBlocks.add(block);
          break;
        case 2:
          constructorBlocks.add(block);
          break;
        case 3:
          nonConstructorOtherBlocks.add(block);
          break;
        case 4:
          getterBlocks.add(block);
          break;
        case 5:
          methodBlocks.add(block);
          break;
        default:
          nonConstructorOtherBlocks.add(block);
          break;
      }
    }

    return [
      ...staticConstBlocks,
      ...constructorBoundBlocks,
      ...constructorBlocks,
      ...nonConstructorOtherBlocks,
      ...getterBlocks,
      ...methodBlocks,
    ];
  }

  static bool _hasRequiredSingleBlankLines(
    ClassLayoutSnapshot snapshot,
    List<MemberBlock> orderedBlocks,
  ) {
    if (orderedBlocks.length < 2) {
      return true;
    }

    for (var i = 0; i < orderedBlocks.length - 1; i++) {
      final first = orderedBlocks[i];
      final second = orderedBlocks[i + 1];
      if (planNormalizeExactSingleBlankLine(snapshot, first, second) != null) {
        return false;
      }
    }
    return true;
  }

  static bool _isSameOrder(
    List<MemberBlock> current,
    List<MemberBlock> target,
  ) {
    if (current.length != target.length) {
      return false;
    }
    for (var i = 0; i < current.length; i++) {
      if (current[i].index != target[i].index) {
        return false;
      }
    }
    return true;
  }

  static String _newline(String content) {
    return content.contains('\r\n') ? '\r\n' : '\n';
  }

  static int _nonConstructorMemberCategory(ClassMember member) {
    if (member is MethodDeclaration) {
      return member.isGetter ? 1 : 2;
    }
    return 0;
  }

  static String _classMemberIndentation(ClassLayoutSnapshot snapshot) {
    for (final block in snapshot.memberBlocks) {
      final linePrefix = snapshot.indentationBefore(block.start);
      if (linePrefix.isNotEmpty && linePrefix.trim().isEmpty) {
        return linePrefix;
      }
    }

    final body = snapshot.classNode.body as BlockClassBody;
    final classLinePrefix = snapshot.indentationBefore(body.leftBracket.offset);
    final classIndentation = _leadingWhitespace(classLinePrefix);
    return '$classIndentation  ';
  }

  static String _leadingWhitespace(String text) {
    final match = RegExp(r'^[ \t]*').firstMatch(text);
    return match?.group(0) ?? '';
  }
}

final class PlannedTextEdit {
  final int offset;
  final int length;
  final String replacement;

  const PlannedTextEdit({
    required this.offset,
    required this.length,
    required this.replacement,
  });
}

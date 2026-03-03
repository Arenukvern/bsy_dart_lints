import 'package:bsy_dart_lints/src/layout/class_layout_snapshot.dart';
import 'package:bsy_dart_lints/src/layout/member_block.dart';
import 'package:analyzer/dart/ast/ast.dart';

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

abstract final class LayoutPlanner {
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
    return 2;
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
    if (snapshot.constructorBoundFieldBlocks.isEmpty) {
      return null;
    }
    if (!canSafelyReorder(snapshot)) {
      return null;
    }

    final staticConstBlocks = <MemberBlock>[];
    final constructorBoundBlocks = <MemberBlock>[];
    final otherBlocks = <MemberBlock>[];

    for (final block in snapshot.memberBlocks) {
      if (block.isStaticConstField) {
        staticConstBlocks.add(block);
      } else if (snapshot.isConstructorBoundFieldBlock(block)) {
        constructorBoundBlocks.add(block);
      } else {
        otherBlocks.add(block);
      }
    }

    final ordered = [
      ...staticConstBlocks,
      ...constructorBoundBlocks,
      ...otherBlocks,
    ];

    if (_isSameOrder(snapshot.memberBlocks, ordered)) {
      return null;
    }
    return ordered;
  }

  static List<MemberBlock>? planStaticConstBeforeFieldsAndConstructors(
    ClassLayoutSnapshot snapshot,
  ) {
    final staticConstBlocks = snapshot.staticConstBlocks;
    if (staticConstBlocks.isEmpty) {
      return null;
    }
    if (!canSafelyReorder(snapshot, requireSafeCtorBoundFields: false)) {
      return null;
    }

    final nonStaticConst = snapshot.memberBlocks
        .where((block) => !block.isStaticConstField)
        .toList(growable: false);
    final insertionIndex = nonStaticConst.indexWhere(
      (block) => block.isField || block.isConstructor,
    );
    if (insertionIndex == -1) {
      return null;
    }

    final ordered = [
      ...nonStaticConst.take(insertionIndex),
      ...staticConstBlocks,
      ...nonStaticConst.skip(insertionIndex),
    ];

    if (_isSameOrder(snapshot.memberBlocks, ordered)) {
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

    final rewrittenBody = StringBuffer();
    rewrittenBody.write(newLine);
    for (var i = 0; i < orderedBlocks.length; i++) {
      final block = orderedBlocks[i];
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
    final gapText = snapshot.gapTextBetween(first, second);
    if (gapText.contains('//') || gapText.contains('/*')) {
      return null;
    }

    final newLine = _newline(snapshot.content);
    final indentation = snapshot.indentationBefore(second.start);
    final replacement = '$newLine$newLine$indentation';
    if (gapText == replacement) {
      return null;
    }

    return PlannedTextEdit(
      offset: first.end,
      length: second.start - first.end,
      replacement: replacement,
    );
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
}

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Android TalkBack 등 스크린 리더용 Semantics 헬퍼
class TogedogA11y {
  TogedogA11y._();

  /// 화면 진입 시 읽히는 화면 이름
  static Widget screen({
    required String name,
    required Widget child,
  }) {
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: name,
      child: child,
    );
  }

  /// 탭 가능한 버튼 (아이콘·커스텀 GestureDetector 포함)
  static Widget button({
    required String label,
    String? hint,
    bool enabled = true,
    bool selected = false,
    required Widget child,
  }) {
    final fullLabel = hint == null ? label : '$label. $hint';
    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      label: fullLabel,
      excludeSemantics: true,
      child: child,
    );
  }

  /// 목록·설정 행 등
  static Widget link({
    required String label,
    String? hint,
    bool enabled = true,
    required Widget child,
  }) {
    return button(
      label: label,
      hint: hint,
      enabled: enabled,
      child: child,
    );
  }

  /// 라디오·선택 카드
  static Widget selectable({
    required String label,
    String? description,
    required bool selected,
    required Widget child,
  }) {
    final state = selected ? '선택됨' : '선택 안 됨';
    final fullLabel = description == null
        ? '$label, $state'
        : '$label, $description, $state';
    return Semantics(
      button: true,
      selected: selected,
      label: fullLabel,
      excludeSemantics: true,
      child: child,
    );
  }

  /// 섹션 제목
  static Widget header({
    required String label,
    required Widget child,
  }) {
    return Semantics(
      header: true,
      label: label,
      child: child,
    );
  }

  /// 입력 필드
  static Widget textField({
    required String label,
    String? value,
    String? hint,
    required Widget child,
  }) {
    return Semantics(
      textField: true,
      label: label,
      hint: hint,
      value: value,
      child: child,
    );
  }

  /// 체크박스·동의 항목
  static Widget checkbox({
    required String label,
    required bool checked,
    required Widget child,
  }) {
    return Semantics(
      checked: checked,
      label: label,
      child: child,
    );
  }

  /// 장식용 이미지·아이콘 — TalkBack에서 건너뜀
  static Widget decorative(Widget child) => ExcludeSemantics(child: child);

  static Widget exclude(Widget child) => ExcludeSemantics(child: child);

  static void announce(BuildContext context, String message) {
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      Directionality.of(context),
    );
  }
}

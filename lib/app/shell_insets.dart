import 'package:flutter/material.dart';

/// 与 [MainShell] 底部导航一致：外层 `bottom: safe + 6`，内部高度 `72`，
/// 另加少量留白，避免 `extendBody: true` 时子页内容与 TabBar 重叠。
double mainShellBottomContentPadding(BuildContext context) {
  final safe = MediaQuery.paddingOf(context).bottom;
  const outerGap = 6.0;
  const barHeight = 72.0;
  const breathingRoom = 20.0;
  return safe + outerGap + barHeight + breathingRoom;
}

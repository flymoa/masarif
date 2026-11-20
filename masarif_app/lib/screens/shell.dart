import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:masarif/widgets/icons.dart';

import '../l10n/strings.dart';
import '../theme.dart';

/// Barre l ta7t b7al mockup V2: 88px (70 + 18 lta7t), 4 onglets + "+" f lwost.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final bottom = math.max(18.0, MediaQuery.of(context).padding.bottom);

    Widget tab(int i, String off, String on, String label) {
      final sel = shell.currentIndex == i;
      return Expanded(
        child: Semantics(
          selected: sel,
          button: true,
          label: label,
          child: InkWell(
            onTap: () => shell.goBranch(i, initialLocation: i == shell.currentIndex),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Ic(sel ? on : off, size: 22, color: sel ? c.brandFg : c.navMuted),
              const SizedBox(height: 4),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? c.brandFg : c.navMuted)),
            ]),
          ),
        ),
      );
    }

    return Scaffold(
      body: shell,
      extendBody: true,
      bottomNavigationBar: SizedBox(
        height: 70 + bottom,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.only(bottom: bottom),
              decoration: BoxDecoration(color: c.surface, border: Border(top: BorderSide(color: c.divider))),
              child: Row(children: [
                tab(0, I.home_outlined, I.home_rounded, S.tabHome),
                tab(1, I.list_alt_outlined, I.list_alt_rounded, S.tabTx),
                const Expanded(child: SizedBox()),
                tab(2, I.bar_chart_outlined, I.bar_chart_rounded, S.tabStats),
                tab(3, I.person_outline_rounded, I.person_rounded, S.tabProfile),
              ]),
            ),
          ),
          // "+": 56px + 7alqa 5px b loun l barre, tal3 8px fo9 l 7achiya.
          Positioned(
            top: -13,
            left: 0,
            right: 0,
            child: Center(
              child: Semantics(
                button: true,
                label: S.addTx,
                child: GestureDetector(
                  onTap: () => context.push('/add'),
                  child: Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(color: c.fabBg, shape: BoxShape.circle, border: Border.all(color: c.surface, width: 5)),
                    alignment: Alignment.center,
                    child: Ic(I.add_rounded, color: c.fabFg, size: 24, strokeWidth: 2.6),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

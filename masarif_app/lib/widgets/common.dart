import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:masarif/widgets/icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../data/repo.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'khatam_logo.dart';

void toast(BuildContext context, String msg, {String? action, VoidCallback? onAction, int seconds = 3}) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    content: Text(msg),
    duration: Duration(seconds: seconds),
    action: action == null ? null : SnackBarAction(label: action, onPressed: onAction ?? () {}),
  ));
}

class Logo extends StatelessWidget {
  const Logo({super.key, this.size = 36});
  final double size;
  @override
  Widget build(BuildContext context) => KhatamLogo(size: size);
}

/// Icone dyal categorie: morab3 mdawwer b loun fat7 + icone b nfs l loun ghame9.
/// Netflix o Spotify 3ndhom tile khassa.
class CatIcon extends StatelessWidget {
  const CatIcon(this.cat, {super.key, this.size = 46});
  final Cat cat;
  final double size;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final radius = BorderRadius.circular(size * 0.3);
    switch (cat.iconKey) {
      case 'netflix':
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: radius),
          child: Text('N', style: display(size * 0.52, color: const Color(0xFFE50914), weight: FontWeight.w800)),
        );
      case 'spotify':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: const Color(0xFF1DB954), borderRadius: radius),
          child: CustomPaint(painter: _WavesPainter()),
        );
      case 'work':
        if (cat.type == TxType.income) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: AppColors.deepGreen, borderRadius: radius),
            child: Ic(cat.iconData, color: AppColors.gold, size: size * 0.48),
          );
        }
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: cat.bg(b), borderRadius: radius),
      child: Ic(cat.iconData, color: cat.fg(b), size: size * 0.48),
    );
  }
}

class _WavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = const Color(0xFF111111)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = s.width * 0.09;
    for (var i = 0; i < 3; i++) {
      final y = s.height * (0.36 + i * 0.15);
      final w = s.width * (0.56 - i * 0.1);
      final path = Path()
        ..moveTo(s.width / 2 - w / 2, y)
        ..quadraticBezierTo(s.width / 2, y - s.height * 0.08, s.width / 2 + w / 2, y + s.height * 0.03);
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Card2 extends StatelessWidget {
  const Card2({super.key, required this.child, this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 4), this.radius = 20});
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(color: context.c.surface, borderRadius: BorderRadius.circular(radius)),
        child: child,
      );
}

class Divided extends StatelessWidget {
  const Divided(this.children, {super.key});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Column(children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) Divider(height: 1, color: context.c.divider),
          children[i],
        ],
      ]);
}

/// STer dyal mo3amala: carte bayda bo7dha (b7al "Recent activity").
class TxRow extends ConsumerWidget {
  const TxRow(this.t, {super.key, this.showDay = true});
  final Txn t;
  final bool showDay;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final cat = catById(ref.watch(allCatsProvider), t.categoryId);
    final title = t.note.isNotEmpty ? t.note : cat.name;
    final sub = showDay ? '${cat.name} · ${dayLabel(t.date)}, ${hhmm(t.date)}' : '${cat.name} · ${hhmm(t.date)}';
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push('/tx/${t.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            CatIcon(cat),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(sub, style: TextStyle(fontSize: 12, color: c.muted)),
              ]),
            ),
            Text(t.type == TxType.income ? dh(t.amount, sign: true) : dh(-t.amount),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: t.type == TxType.income ? c.positive : c.text)),
          ]),
        ),
      ),
    );
  }
}

/// Onglets (Kolchi / Masarif / Dakhl…).
class Segmented<T> extends StatelessWidget {
  const Segmented({super.key, required this.items, required this.value, required this.onChanged});
  final Map<T, String> items;
  final T value;
  final ValueChanged<T> onChanged;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
      child: Row(children: [
        for (final e in items.entries)
          Expanded(
            child: Semantics(
              selected: e.key == value,
              button: true,
              child: GestureDetector(
                onTap: () => onChanged(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: e.key == value ? c.segActive : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                  child: Text(e.value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: e.key == value ? FontWeight.w600 : FontWeight.w500,
                        color: e.key == value ? Colors.white : c.muted,
                      )),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

class SyncPill extends ConsumerWidget {
  const SyncPill({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final pending = ref.watch(pendingSyncProvider).value ?? false;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Ic(pending ? I.cloud_off_outlined : I.cloud_done_outlined, size: 14, color: pending ? c.goldInk : c.positive),
      const SizedBox(width: 6),
      Text(pending ? 'Kaytsenna l internet…' : S.synced, style: TextStyle(fontSize: 12, color: c.muted)),
    ]);
  }
}

/// Bouton dayer 46px (rje3, bi7, filtre…).
class CircleBtn extends StatelessWidget {
  const CircleBtn({super.key, required this.icon, required this.onTap, required this.label, this.onDark = false, this.filled = false, this.badge = false});
  final String icon;
  final VoidCallback? onTap;
  final String label;
  final bool onDark, filled, badge;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final bg = filled ? c.fabBg : (onDark ? Colors.white.withValues(alpha: 0.12) : c.surface);
    final fg = filled ? c.fabFg : (onDark ? Colors.white : c.text);
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            border: (filled || onDark) ? null : Border.all(color: c.border),
          ),
          child: Stack(alignment: Alignment.center, children: [
            Ic(icon, color: fg, size: 21),
            if (badge)
              Positioned(top: 11, right: 12, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle))),
          ]),
        ),
      ),
    );
  }
}

class BackBox extends StatelessWidget {
  const BackBox({super.key, this.onDark = false});
  final bool onDark;
  @override
  Widget build(BuildContext context) => CircleBtn(
        icon: I.chevron_left_rounded,
        label: S.undo,
        onDark: onDark,
        onTap: () => context.canPop() ? context.pop() : context.go('/'),
      );
}

/// Header: rje3 + titre f lwost + (ikhtiyari) bouton 3la l imin. Nfs l 3lou f ga3 les pages.
class TopBar extends StatelessWidget {
  const TopBar(this.title, {super.key, this.trailing, this.onDark = false});
  final String title;
  final Widget? trailing;
  final bool onDark;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Row(children: [
          BackBox(onDark: onDark),
          Expanded(child: Text(title, textAlign: TextAlign.center, style: display(18, color: onDark ? Colors.white : null))),
          SizedBox(width: 46, child: trailing),
        ]),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
        child: Row(children: [
          Expanded(child: Text(text, style: display(17))),
          if (trailing != null) trailing!,
        ]),
      );
}

class CapsTitle extends StatelessWidget {
  const CapsTitle(this.text, {super.key, this.trailing});
  final String text;
  final String? trailing;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
        child: Row(children: [
          Expanded(child: Text(text, style: capsLabel(context.c.muted))),
          if (trailing != null) Text(trailing!, style: capsLabel(context.c.muted)),
        ]),
      );
}

class ProgressBar extends StatelessWidget {
  const ProgressBar(this.value, {super.key, this.color, this.track, this.height = 6});
  final double value;
  final Color? color, track;
  final double height;
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: LinearProgressIndicator(
          value: value.clamp(0, 1).toDouble(),
          minHeight: height,
          color: color ?? context.c.brandFg,
          backgroundColor: track ?? context.c.divider,
        ),
      );
}

/// Avatar: tswira dyal l user ila kayna, wla l 7arf lwl.
class Avatar extends ConsumerWidget {
  const Avatar({super.key, this.size = 46});
  final double size;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(profileProvider).value;
    final name = p?.name ?? '';
    final photo = p?.photo;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: AppColors.deepGreen, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: (photo != null && photo.isNotEmpty)
          ? Image.memory(base64Decode(photo), width: size, height: size, fit: BoxFit.cover, gaplessPlayback: true)
          : Text(name.isEmpty ? '?' : name[0].toUpperCase(), style: display(size * 0.4, color: AppColors.gold)),
    );
  }
}

/// Clavier ar9am (b7al design V2).
class NumPad extends StatelessWidget {
  const NumPad({super.key, required this.onKey});
  final ValueChanged<String> onKey;
  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', ',', '0', '<'];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.6,
      children: [
        for (final k in keys)
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onKey(k),
            child: Center(
              child: k == '<'
                  ? Ic(I.backspace_outlined, color: context.c.text, semanticLabel: S.delete)
                  : Text(k, style: display(24, weight: FontWeight.w500)),
            ),
          ),
      ],
    );
  }
}

/// Tbddel string dyal mablagh b clavier (max 2 ar9am ba3d l fasila).
String applyKey(String current, String k) {
  if (k == '<') return current.isEmpty ? current : current.substring(0, current.length - 1);
  if (k == ',') return current.contains(',') ? current : (current.isEmpty ? '0,' : '$current,');
  final i = current.indexOf(',');
  if (i >= 0 && current.length - i > 2) return current;
  if (current == '0') return k;
  if (current.replaceAll(',', '').length >= 9) return current;
  return current + k;
}

/// Mablagh kbir f lwost (b7al "50 | DH").
class AmountDisplay extends StatelessWidget {
  const AmountDisplay(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(text.isEmpty ? '0' : text, style: display(50, color: text.isEmpty ? context.c.muted : null).copyWith(letterSpacing: -2)),
        Container(width: 2, height: 40, margin: const EdgeInsets.symmetric(horizontal: 6), color: AppColors.gold),
        Text('DH', style: display(22, color: context.c.muted)),
      ]);
}

class QuickChips extends StatelessWidget {
  const QuickChips({super.key, required this.values, required this.selected, required this.onPick});
  final List<int> values;
  final String selected;
  final ValueChanged<int> onPick;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
      for (final v in values)
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onPick(v),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: selected == '$v' ? c.segActive : Colors.transparent,
              border: selected == '$v' ? null : Border.all(color: c.border),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('$v', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected == '$v' ? Colors.white : c.text)),
          ),
        ),
    ]);
  }
}

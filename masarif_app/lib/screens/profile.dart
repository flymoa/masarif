import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:masarif/widgets/icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../data/repo.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _pickPhoto(BuildContext context, WidgetRef ref) async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 320, maxHeight: 320, imageQuality: 70);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.length > 300 * 1024) {
        if (context.mounted) toast(context, 'Tswira kbira bzaf, khtar wa7da khra');
        return;
      }
      await ref.read(repoProvider)?.setProfile({'photo': base64Encode(bytes)});
    } catch (_) {
      if (context.mounted) toast(context, 'Ma 9dertch n7tt tswira');
    }
  }

  Future<void> _editName(BuildContext context, WidgetRef ref, String current) async {
    final ctrl = TextEditingController(text: current);
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final v = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.nameEmail),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(controller: ctrl, autofocus: true, decoration: const InputDecoration(labelText: S.name)),
          const SizedBox(height: 12),
          Text(email, style: TextStyle(color: ctx.c.muted)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text(S.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text(S.save)),
        ],
      ),
    );
    if (v != null && v.isNotEmpty) {
      ref.read(repoProvider)?.setProfile({'name': v});
      FirebaseAuth.instance.currentUser?.updateDisplayName(v);
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final pass = TextEditingController();
    String? error;
    var busy = false;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text(S.deleteAccountTitle),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(S.deleteAccountBody, style: TextStyle(height: 1.5)),
            const SizedBox(height: 16),
            TextField(controller: pass, obscureText: true, decoration: InputDecoration(hintText: S.password, prefixIcon: const Ic(I.lock_outline), errorText: error)),
          ]),
          actions: [
            TextButton(onPressed: busy ? null : () => Navigator.pop(ctx), child: const Text(S.cancel)),
            TextButton(
              onPressed: busy
                  ? null
                  : () async {
                      setLocal(() => (busy = true, error = null));
                      final user = FirebaseAuth.instance.currentUser!;
                      try {
                        await user.reauthenticateWithCredential(EmailAuthProvider.credential(email: user.email!, password: pass.text));
                        await ref.read(repoProvider)!.deleteAllData();
                        await user.delete();
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) toast(context, S.deleteAccountDone);
                      } on FirebaseAuthException catch (e) {
                        setLocal(() => (busy = false, error = e.code == 'network-request-failed' ? S.offline : S.badLogin));
                      }
                    },
              child: Text(S.delete, style: TextStyle(color: ctx.c.danger, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final p = ref.watch(profileProvider).value;
    final user = FirebaseAuth.instance.currentUser;
    final name = p?.name ?? user?.displayName ?? '';
    final email = user?.email ?? p?.email ?? '';
    final repo = ref.watch(repoProvider);
    final dark = p?.theme == 'dark' || (p?.theme != 'light' && context.isDark);

    Widget iconBox(String i, {bool gold = false}) => Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: gold ? c.goldSoft : c.chipActive, borderRadius: BorderRadius.circular(12)),
          child: Ic(i, size: 19, color: gold ? c.goldInk : c.brandFg),
        );
    Widget row(String icon, String title, {String? sub, Widget? trailing, VoidCallback? onTap, bool gold = false}) => InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 58),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              iconBox(icon, gold: gold),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontSize: 15)),
                  if (sub != null) Text(sub, style: TextStyle(fontSize: 11, color: c.muted)),
                ]),
              ),
              trailing ?? Ic(I.chevron_right_rounded, color: c.navMuted),
            ]),
          ),
        );
    Widget themePill(String value, String label) {
      final sel = (value == 'dark') == dark;
      return GestureDetector(
        onTap: () => repo?.setProfile({'theme': value}),
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: sel ? (dark ? c.segActive : c.surface) : Colors.transparent, borderRadius: BorderRadius.circular(9)),
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.w500, color: sel ? (dark ? Colors.white : c.text) : c.muted)),
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 110),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(height: 46, child: Align(alignment: Alignment.centerLeft, child: Text(S.tabProfile, style: display(24)))),
          ),
          const SizedBox(height: 10),
          Center(
            child: SizedBox(
              width: 96,
              height: 96,
              child: Stack(children: [
                const Avatar(size: 92),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Semantics(
                    button: true,
                    label: S.changePhoto,
                    child: GestureDetector(
                      onTap: () => _pickPhoto(context, ref),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: AppColors.gold, shape: BoxShape.circle, border: Border.all(color: c.bg, width: 3)),
                        child: const Ic(I.photo_camera_outlined, size: 17, color: AppColors.onGold),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 10),
          Text(name, textAlign: TextAlign.center, style: display(19)),
          Text(email, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: c.muted)),
          const SizedBox(height: 18),
          Card2(
            radius: 22,
            child: Divided([
              row(I.person_outline_rounded, S.nameEmail, onTap: () => _editName(context, ref, name)),
              row(I.grid_view_rounded, S.categories, onTap: () => context.push('/categories')),
              row(I.savings_outlined, S.savingsAuto,
                  sub: S.savingsAutoSub,
                  gold: true,
                  trailing: Switch(value: p?.autoSavings ?? false, onChanged: (v) => repo?.setProfile({'autoSavings': v}))),
              row(I.dark_mode_outlined, S.themeTitle,
                  trailing: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(12)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [themePill('light', S.themeShortLight), themePill('dark', S.themeShortDark)]),
                  )),
              row(I.notifications_none_rounded, S.notifications, onTap: () => context.push('/notifs')),
            ]),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: c.surface, foregroundColor: c.text, minimumSize: const Size.fromHeight(52)),
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Ic(I.logout_rounded, size: 18),
            label: const Text(S.logout),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: c.danger, minimumSize: const Size.fromHeight(44)),
            onPressed: () => _deleteAccount(context, ref),
            child: const Text(S.deleteAccount, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

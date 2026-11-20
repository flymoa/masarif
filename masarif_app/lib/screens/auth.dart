import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:masarif/widgets/icons.dart';
import 'package:go_router/go_router.dart';

import '../l10n/strings.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/khatam_logo.dart';
import '../widgets/zellige.dart';

String _authError(FirebaseAuthException e) => switch (e.code) {
      'email-already-in-use' => S.emailExists,
      'invalid-email' => S.badEmail,
      'weak-password' => S.passMin,
      'network-request-failed' => S.offline,
      _ => S.badLogin,
    };

String? _emailVal(String? v) =>
    (v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) ? S.badEmail : null;

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.controller, this.obscure = false, this.validator, this.keyboard, this.suffix, this.autofill});
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final String? Function(String?)? validator;
  final TextInputType? keyboard;
  final Widget? suffix;
  final Iterable<String>? autofill;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.c.muted)),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          keyboardType: keyboard,
          autofillHints: autofill,
          decoration: InputDecoration(suffixIcon: suffix),
        ),
      ]);
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);
  final String? text;
  @override
  Widget build(BuildContext context) => text == null
      ? const SizedBox.shrink()
      : Padding(padding: const EdgeInsets.only(top: 10), child: Text(text!, style: TextStyle(color: context.c.danger, fontWeight: FontWeight.w600)));
}

/// L jiha l khdra lfo9 b zellige li kaytghbber l ta7t.
class _GreenTop extends StatelessWidget {
  const _GreenTop({required this.height, required this.child});
  final double height;
  final Widget child;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: Stack(fit: StackFit.expand, children: [
          const ZelligeBackground(color: AppColors.deepGreen, fadeFrom: Alignment.bottomCenter, fadeTo: Alignment.topCenter, opacity: 0.45, tile: 38, stops: [0.1, 1.0]),
          SafeArea(bottom: false, child: child),
        ]),
      );
}

/// Waraqa fat7a li katl3 mn l ta7t.
class _Sheet extends StatelessWidget {
  const _Sheet({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(color: context.c.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
        child: SafeArea(top: false, child: child),
      );
}

Widget _busyOr(bool busy, String label) =>
    busy ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onGold)) : Text(label);

// ───────────────────────── Dkhol
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _show = false, _busy = false;
  String? _error;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => (_busy = true, _error = null));
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.text.trim(), password: _pass.text);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _authError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: AppColors.deepGreen,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: Column(children: [
            _GreenTop(
              height: 330,
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const KhatamLogo(size: 96),
                  const SizedBox(height: 12),
                  Text(S.appName, style: display(36, color: Colors.white, weight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(S.slogan.replaceAll('\n', ' '), style: const TextStyle(fontSize: 15, color: AppColors.gold)),
                ]),
              ),
            ),
            _Sheet(
              child: AutofillGroup(
                child: Form(
                  key: _form,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    _Field(label: S.email, controller: _email, validator: _emailVal, keyboard: TextInputType.emailAddress, autofill: const [AutofillHints.email]),
                    const SizedBox(height: 16),
                    _Field(
                      label: S.password,
                      controller: _pass,
                      obscure: !_show,
                      autofill: const [AutofillHints.password],
                      validator: (v) => (v == null || v.isEmpty) ? S.required : null,
                      suffix: IconButton(
                        tooltip: 'Werri mot de passe',
                        icon: Ic(_show ? I.visibility_off_outlined : I.visibility_outlined),
                        onPressed: () => setState(() => _show = !_show),
                      ),
                    ),
                    Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => context.push('/forgot'), child: const Text(S.forgot))),
                    _ErrorText(_error),
                    const SizedBox(height: 8),
                    FilledButton(onPressed: _busy ? null : _submit, child: _busyOr(_busy, S.login)),
                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(S.noAccount, style: TextStyle(color: c.muted, fontSize: 14)),
                      const SizedBox(width: 6),
                      TextButton(onPressed: () => context.push('/signup'), child: const Text(S.signup)),
                    ]),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ───────────────────────── T9eyd db
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => (_busy = true, _error = null));
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.text.trim(), password: _pass.text);
      await cred.user!.updateDisplayName(_name.text.trim());
      await cred.user!.sendEmailVerification();
      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'autoSavings': false,
        'hiddenCats': [],
      });
      if (mounted) toast(context, S.verifySent, seconds: 5);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _authError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: AppColors.deepGreen,
      body: SingleChildScrollView(
        child: Column(children: [
          _GreenTop(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const BackBox(onDark: true),
                const SizedBox(height: 22),
                Text(S.signup, style: display(28, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Compte wa7ed, data dyalk f ga3 l appareils.', style: const TextStyle(fontSize: 14, color: AppColors.onBrandMuted)),
              ]),
            ),
          ),
          _Sheet(
            child: Form(
              key: _form,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _Field(label: S.name, controller: _name, validator: (v) => (v == null || v.trim().isEmpty) ? S.required : null),
                const SizedBox(height: 14),
                _Field(label: S.email, controller: _email, validator: _emailVal, keyboard: TextInputType.emailAddress),
                const SizedBox(height: 14),
                _Field(label: S.password, controller: _pass, obscure: true, validator: (v) => (v == null || v.length < 8) ? S.passMin : null),
                Padding(padding: const EdgeInsets.only(top: 6), child: Text(S.passMin, style: TextStyle(fontSize: 11, color: c.muted))),
                const SizedBox(height: 14),
                _Field(label: S.password2, controller: _pass2, obscure: true, validator: (v) => v != _pass.text ? S.passMismatch : null),
                _ErrorText(_error),
                const SizedBox(height: 20),
                FilledButton(onPressed: _busy ? null : _submit, child: _busyOr(_busy, S.save)),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(S.haveAccount, style: TextStyle(color: c.muted, fontSize: 14)),
                  const SizedBox(width: 6),
                  TextButton(onPressed: () => context.go('/login'), child: const Text(S.login)),
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ───────────────────────── Nsit l mot de passe
class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});
  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _busy = false, _sent = false;
  String? _error;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => (_busy = true, _error = null));
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email.text.trim());
      setState(() => _sent = true);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _authError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Form(
            key: _form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Align(alignment: Alignment.centerLeft, child: BackBox()),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(color: AppColors.deepGreen, borderRadius: BorderRadius.circular(24)),
                  child: const Ic(I.lock_reset_rounded, color: AppColors.gold, size: 34),
                ),
              ),
              const SizedBox(height: 22),
              Text(S.forgot, style: display(28)),
              const SizedBox(height: 10),
              Text(S.forgotSub, style: TextStyle(fontSize: 15, color: c.muted, height: 1.55)),
              const SizedBox(height: 26),
              _Field(label: S.email, controller: _email, validator: _emailVal, keyboard: TextInputType.emailAddress),
              _ErrorText(_error),
              const SizedBox(height: 16),
              FilledButton(onPressed: _busy ? null : _submit, child: _busyOr(_busy, S.send)),
              if (_sent) ...[
                const SizedBox(height: 18),
                Card2(
                  radius: 18,
                  padding: const EdgeInsets.all(14),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: c.chipActive, borderRadius: BorderRadius.circular(12)),
                      child: Ic(I.check_rounded, color: c.positive, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text(S.forgotSent, style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 3),
                        Text(S.forgotSentSub, style: TextStyle(fontSize: 13, color: c.muted, height: 1.45)),
                      ]),
                    ),
                  ]),
                ),
              ],
              const SizedBox(height: 24),
              Center(child: TextButton(onPressed: () => context.go('/login'), child: const Text(S.backToLogin))),
            ]),
          ),
        ),
      ),
    );
  }
}

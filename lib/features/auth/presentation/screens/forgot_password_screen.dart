import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_hub/core/theme/app_theme.dart';
import 'package:barber_hub/shared/widgets/app_widgets.dart';
import 'package:barber_hub/features/auth/presentation/providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;
  late AnimationController _anim;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
  }

  @override
  void dispose() { _anim.dispose(); _emailCtrl.dispose(); super.dispose(); }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await ref.read(authNotifierProvider.notifier).sendPasswordReset(_emailCtrl.text);
    if (!mounted) return;
    setState(() => _sent = true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.mark_email_read_outlined, color: AppTheme.gold, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text('Link enviado para ${_emailCtrl.text}', overflow: TextOverflow.ellipsis)),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider) is AuthLoading;
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.lock_reset_rounded, color: AppTheme.gold, size: 28),
                    ),
                    const SizedBox(height: 28),
                    Text('Recuperar\nsenha.', style: Theme.of(context).textTheme.displayMedium?.copyWith(height: 1.1)),
                    const SizedBox(height: 8),
                    const GoldAccent(),
                    const SizedBox(height: 16),
                    Text('Informe o e-mail cadastrado e enviaremos um link para redefinição de senha.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6)),
                    const SizedBox(height: 40),
                    if (!_sent) ...[
                      AppTextField(
                        label: 'E-mail', hint: 'seu@email.com',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: _handleSend,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe o e-mail';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'E-mail inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(label: 'Enviar link', onPressed: _handleSend, isLoading: isLoading),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                          color: AppTheme.gold.withOpacity(0.06),
                        ),
                        child: Column(children: [
                          const Icon(Icons.check_circle_outline_rounded, color: AppTheme.gold, size: 40),
                          const SizedBox(height: 16),
                          Text('E-mail enviado!', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.gold), textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          Text('Verifique sua caixa de entrada.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5), textAlign: TextAlign.center),
                        ]),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity, height: 56,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.inputBorder),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                          ),
                          child: Text('VOLTAR AO LOGIN', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.textPrimary, fontSize: 13)),
                        ),
                      ),
                    ],
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

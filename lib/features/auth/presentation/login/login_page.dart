import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:odoocrm/core/constants/app_constants.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
import 'package:odoocrm/features/auth/presentation/providers/auth_notifier.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final obscurePassword = useState(true);
    final keepSignedIn = useState(true);
    final isSubmitting = useState(false);
    final errorMessage = useState<String?>(null);
    final theme = Theme.of(context);
    final host =
        Uri.tryParse(AppConstants.baseUrl)?.host ?? AppConstants.baseUrl;

    Future<void> onLogin() async {
      errorMessage.value = null;
      if (!(formKey.currentState?.validate() ?? false)) return;

      isSubmitting.value = true;
      final error = await ref.read(authNotifierProvider.notifier).login(
            username: usernameController.text,
            password: passwordController.text,
          );
      isSubmitting.value = false;

      if (error != null) {
        errorMessage.value = error;
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(26, 74, 26, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppTheme.navy,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'DL',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            letterSpacing: -0.03,
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        'Sign in to CRM',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.025,
                          height: 1.2,
                          fontSize: 27,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use your existing Odoo credentials. Your permissions and record rules carry over.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textBody,
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Email',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.01,
                        ),
                      ),
                      const SizedBox(height: 7),
                      TextFormField(
                        controller: usernameController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'you@digilawyer.ai',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Password',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 7),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword.value,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => onLogin(),
                        style: TextStyle(
                          fontSize: obscurePassword.value ? 17 : 15,
                          letterSpacing: obscurePassword.value ? 3 : 0,
                        ),
                        decoration: InputDecoration(
                          hintText: '•••••••••',
                          suffixIcon: TextButton(
                            onPressed: () =>
                                obscurePassword.value = !obscurePassword.value,
                            child: Text(
                              obscurePassword.value ? 'SHOW' : 'HIDE',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.navy,
                              ),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          SizedBox(
                            width: 19,
                            height: 19,
                            child: Checkbox(
                              value: keepSignedIn.value,
                              onChanged: (v) =>
                                  keepSignedIn.value = v ?? false,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const SizedBox(width: 9),
                          const Expanded(
                            child: Text(
                              'Keep me signed in',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (errorMessage.value != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.lostBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.lostBorder),
                          ),
                          child: Text(
                            errorMessage.value!,
                            style: const TextStyle(color: AppTheme.error),
                          ),
                        ),
                      ],
                      const SizedBox(height: 26),
                      FilledButton(
                        onPressed: isSubmitting.value ? null : onLogin,
                        child: isSubmitting.value
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Log in'),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.scaffold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'DB',
                        style: AppTheme.mono(
                          fontSize: 11,
                          color: AppTheme.textBody,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          host,
                          style: AppTheme.mono(
                            fontSize: 11,
                            color: AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

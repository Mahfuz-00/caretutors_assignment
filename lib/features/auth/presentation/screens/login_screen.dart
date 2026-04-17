import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final wasSubmitted = useState(false);

    final authState = ref.watch(authControllerProvider);

    final isBackendError = authState.maybeWhen(
      error: (err, _) {
        final errorStr = err.toString().toLowerCase();
        return errorStr.contains('invalid-credential') ||
            errorStr.contains('user-not-found') ||
            errorStr.contains('wrong-password');
      },
      orElse: () => false,
    );

    void handleLogin() {
      wasSubmitted.value = true; // Now the fields will "listen" to inputs
      if (formKey.currentState?.validate() ?? false) {
        ref.read(authControllerProvider.notifier).login(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
      }
    }

    const staticBgColor = Color(0xFFF8F9FE);

    return Scaffold(
      backgroundColor: staticBgColor,
      appBar: AppBar(
        backgroundColor: staticBgColor,
        surfaceTintColor: staticBgColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              final currentMode = ref.read(themeModeProvider);
              ref.read(themeModeProvider.notifier).state =
              currentMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
            },
            icon: Icon(
              ref.watch(themeModeProvider) == ThemeMode.light
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          autovalidateMode: wasSubmitted.value
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(flex: 3),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.notes_rounded, color: Colors.white, size: 32),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          "Welcome to Notes",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1C1E),
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sign in to access your secure notes.",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                        const SizedBox(height: 48),

                        AuthTextField(
                          controller: emailController,
                          label: "Email Address",
                          icon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Email is required';
                            return _getBackendEmailError(authState, isBackendError);
                          },
                        ),
                        const SizedBox(height: 20),
                        AuthTextField(
                          controller: passwordController,
                          label: "Password",
                          icon: Icons.lock_outline_rounded,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Password is required';
                            if (isBackendError) return 'Invalid credentials';
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),

                        ElevatedButton(
                          onPressed: authState.isLoading ? null : handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 0,
                          ),
                          child: authState.isLoading
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                              : const Text("Sign In", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const Spacer(flex: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("New here?", style: TextStyle(color: Colors.grey.shade600)),
                            TextButton(
                              onPressed: () {
                                ref.invalidate(authControllerProvider);
                                wasSubmitted.value = false;
                                formKey.currentState?.reset();
                                emailController.clear();
                                passwordController.clear();

                                context.push('/register');
                              },
                              child: const Text("Create Account", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String? _getBackendEmailError(AsyncValue state, bool isCredError) {
    return state.maybeWhen(
      error: (err, _) {
        final errorStr = err.toString().toLowerCase();
        if (errorStr.contains('invalid-email')) return 'Invalid email format';
        if (isCredError) return 'Account not found';
        return null;
      },
      orElse: () => null,
    );
  }
}
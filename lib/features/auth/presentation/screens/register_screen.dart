import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final wasSubmitted = useState(false);

    final authState = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (err, _) {
          if (!err.toString().contains('email-already-in-use')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(err.toString()),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        data: (_) {
          if (previous is AsyncLoading) context.go('/login');
        },
      );
    });

    void handleRegistration() {
      wasSubmitted.value = true;

      if (formKey.currentState?.validate() ?? false) {
        ref.read(authControllerProvider.notifier).register(
          emailController.text.trim(),
          passwordController.text.trim(),
          nameController.text.trim(),
        );
      }
    }

    const staticBgColor = Color(0xFFF8F9FE);

    return Scaffold(
      backgroundColor: staticBgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
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
      body: Form(
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
                    children: [
                      const Spacer(flex: 2),

                      // --- Header Section ---
                      Text(
                        "Create Account",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1C1E),
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Join us to start taking modern notes.",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                      const SizedBox(height: 48),

                      // --- Form Section ---
                      AuthTextField(
                        controller: nameController,
                        label: "Full Name",
                        icon: Icons.person_outline_rounded,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Full name is required';
                          if (val.length < 3) return 'Name is too short';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      AuthTextField(
                        controller: emailController,
                        label: "Email Address",
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Email is required';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                            return 'Enter a valid email address';
                          }
                          return _getBackendEmailError(authState);
                        },
                      ),
                      const SizedBox(height: 20),
                      AuthTextField(
                        controller: passwordController,
                        label: "Password",
                        icon: Icons.lock_outline_rounded,
                        obscureText: true,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Password is required';
                          if (val.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),

                      // --- Action Button ---
                      ElevatedButton(
                        onPressed: authState.isLoading ? null : handleRegistration,
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
                            : const Text("Create Account",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),

                      const Spacer(flex: 3),

                      // --- Footer Section ---
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24, top: 20),
                        child: Text(
                          "By signing up, you agree to our Terms of Service\nand Privacy Policy.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String? _getBackendEmailError(AsyncValue state) {
    return state.maybeWhen(
      error: (err, _) => err.toString().contains('email-already-in-use')
          ? 'This email is already in use.'
          : null,
      orElse: () => null,
    );
  }
}
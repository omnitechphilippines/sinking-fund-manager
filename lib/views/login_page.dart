import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../widgets/buttons/custom_button.dart';
import '../widgets/text_fields/custom_text_field.dart';
import '../controllers/auth_controller.dart';
import '../models/auth_model.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _userIdFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _showPassword = false;
  PackageInfo? info;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) async {
      _userIdFocus.requestFocus();
      info = await PackageInfo.fromPlatform();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    _userIdFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    ref.read(authControllerProvider.notifier).login(_userIdController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthModel>(authControllerProvider, (AuthModel? previous, AuthModel next) {
      if (next.status == AuthStatus.loading) {
        showDialog(context: context, barrierDismissible: false, builder: (BuildContext _) => const Center(child: CircularProgressIndicator()));
      } else {
        if (Navigator.canPop(context)) Navigator.pop(context);
      }

      if (next.status == AuthStatus.success) {
        context.go('/member-management');
      }

      if (next.status == AuthStatus.failure) {
        showDialog(
          context: context,
          builder: (BuildContext _) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              title: const Text('Login Failed'),
              content: Text(next.error.toString().contains('fetch') ? 'Server connection error!' : next.error ?? 'Incorrect user name or password'),
              actions: <Widget>[TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
            ),
        );
      }
    });
    return Scaffold(
      backgroundColor: const Color(0xFF202124),
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 18,
                  children: <Widget>[
                    SizedBox(width: 500, child: Container(margin: const EdgeInsets.all(16), child: Image.asset('assets/images/sinking-fund.jpg'))),
                    const Text('SINKING FUND MANAGER', style: TextStyle(color: Colors.blue, fontSize: 32, fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 450,
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: Colors.grey[300],
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(height: 16),
                              const Text('LOGIN CREDENTIALS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              CustomTextField(prefixIcon: const Icon(Icons.person), controller: _userIdController, hintText: 'User Name', obscureText: false, focusNode: _userIdFocus, onSubmitted: (String _) => _passwordFocus.requestFocus(), radius: 50),
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: _passwordController,
                                hintText: 'Password',
                                obscureText: true,
                                showPassword: _showPassword,
                                onToggle: () => setState(() => _showPassword = !_showPassword),
                                focusNode: _passwordFocus,
                                onSubmitted: (_) => _handleSubmit(),
                                radius: 50,
                                prefixIcon: const Icon(Icons.lock),
                              ),
                              const SizedBox(height: 24),
                              CustomButton(text: 'LOGIN', onTap: _handleSubmit),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(color: const Color(0xFF3F4454), padding: const EdgeInsets.all(8.0), child: Text(info==null?'':'V${info?.version}+${info?.buildNumber}', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall)),
    );
  }
}

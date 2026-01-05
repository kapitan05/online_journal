import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_journal_local/presentation/cubit/auth_state.dart';
import '../cubit/auth_cubit.dart';
import 'registration_wizard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signIn(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Smart Journal', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              
              // Login Button with State Handling
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                  } 
                  // If login succeeds, clear this screen so Home becomes visible
                  else if (state is AuthAuthenticated) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                // If Error, Initial, or Unauthenticated -> Show Button. If Loading -> Show Loader
                builder: (context, state) {
                  if (state is AuthLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                  
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(onPressed: _login, child: const Text('SIGN IN')),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrationWizard()));
                },
                child: const Text('Create an Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_journal_local/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/user_profile.dart';

class RegistrationWizard extends StatefulWidget {
  const RegistrationWizard({super.key});

  @override
  State<RegistrationWizard> createState() => _RegistrationWizardState();
}

class _RegistrationWizardState extends State<RegistrationWizard> {
  int _currentStep = 0;

  // Form Keys for Validation
  final _personalInfoKey = GlobalKey<FormState>();
  final _addressKey = GlobalKey<FormState>();

  // Controllers
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // Regex for Validation email and zip
  final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final _zipRegex = RegExp(r'^\d{5}$'); // Allows exactly 5 digits

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  void _onStepContinue() {
    bool isLastStep = (_currentStep == 2);

    if (isLastStep) {
      // Step 3: SAVE DATA AND SUBMIT all info
      final newUser = UserProfile(
        firstName: _firstNameCtrl.text,
        lastName: _lastNameCtrl.text,
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        street: _streetCtrl.text,
        city: _cityCtrl.text,
        zipCode: _zipCtrl.text,

      );

      context.read<AuthCubit>().signUp(newUser);
      Navigator.pop(context); // Close wizard
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful!')),
      );

    } else {
      // Validate Current Step
      bool isValid = false;
      if (_currentStep == 0) {
        isValid = _personalInfoKey.currentState!.validate();
      } else if (_currentStep == 1) {
        isValid = _addressKey.currentState!.validate();
      }

      if (isValid) {
        setState(() => _currentStep += 1);
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Student Registration')),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        controlsBuilder: (context, details) {
           return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                FilledButton(
                  onPressed: details.onStepContinue,
                  child: Text(_currentStep == 2 ? 'SUBMIT' : 'NEXT'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: Text(_currentStep == 0 ? 'CANCEL' : 'BACK'),
                ),
              ],
            ),
          );
        },
        steps: [
          // STEP 1: Personal Info
          Step(
            title: const Text('Personal'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.editing,
            content: Form(
              key: _personalInfoKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _firstNameCtrl,
                    decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                    validator: (v) => v!.length < 2 ? 'Name too short' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _lastNameCtrl,
                    decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Last Name required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), hintText: 'student@example.com'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email required';
                      if (!_emailRegex.hasMatch(v)) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  // password field
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: true, // Hide text 
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                  ),
                ],
              ),
            ),
          ),

          // STEP 2: Address Info
          Step(
            title: const Text('Address'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.editing,
            content: Form(
              key: _addressKey,
              child: Column(
                children: [
                   TextFormField(
                    controller: _streetCtrl,
                    decoration: const InputDecoration(labelText: 'Street Address', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _cityCtrl,
                          decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _zipCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Zip', border: OutlineInputBorder()),
                          validator: (v) {
                            if (v!.isEmpty) return 'Required';
                            if (!_zipRegex.hasMatch(v)) return '5 Digits';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // STEP 3: Review
          Step(
            title: const Text('Review'),
            isActive: _currentStep >= 2,
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReviewRow('Name:', '${_firstNameCtrl.text} ${_lastNameCtrl.text}'),
                  _buildReviewRow('Email:', _emailCtrl.text),
                  const Divider(),
                  _buildReviewRow('Address:', _streetCtrl.text),
                  _buildReviewRow('City:', '${_cityCtrl.text}, ${_zipCtrl.text}'),
                  const SizedBox(height: 10),
                  const Text('Please verify information before submitting.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
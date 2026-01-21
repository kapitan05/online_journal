import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class PersonalInfoStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final String? selectedImagePath;
  final VoidCallback onPickImage;

  const PersonalInfoStep({
    super.key,
    required this.formKey,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.selectedImagePath,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Image Picker ui
          GestureDetector(
            onTap: onPickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              backgroundImage: selectedImagePath != null
                  ? FileImage(File(selectedImagePath!))
                  : null,
              child: selectedImagePath == null
                  // Update Icon to show "add_a_photo" which implies choice
                  ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Tap to add photo',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 20),

          // user details fields
          TextFormField(
            controller: firstNameCtrl,
            decoration: const InputDecoration(
                labelText: 'First Name', border: OutlineInputBorder()),
            validator: (v) => v!.length < 2 ? 'Name too short' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: lastNameCtrl,
            decoration: const InputDecoration(
                labelText: 'Last Name', border: OutlineInputBorder()),
            validator: (v) => v!.isEmpty ? 'Last Name required' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: emailCtrl,
            decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                hintText: 'student@example.com'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              if (!EmailValidator.validate(value)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          // password field
          TextFormField(
            controller: passwordCtrl,
            obscureText: true, // Hide text
            decoration: const InputDecoration(labelText: 'Password'),
            validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
          ),
        ],
      ),
    );
  }
}

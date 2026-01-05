import 'package:flutter/material.dart';

class AddressStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController streetCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController zipCtrl;

  const AddressStep({
    super.key,
    required this.formKey,
    required this.streetCtrl,
    required this.cityCtrl,
    required this.zipCtrl,
  });

  @override
  Widget build(BuildContext context) {
    // Regex for zip validation
    final zipRegex = RegExp(r'^\d{5}$'); // Allows exactly 5 digits

    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: streetCtrl,
            decoration: const InputDecoration(labelText: 'Street Address', border: OutlineInputBorder()),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: cityCtrl,
                  decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: zipCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Zip', border: OutlineInputBorder()),
                  validator: (v) {
                    if (v!.isEmpty) return 'Required';
                    if (!zipRegex.hasMatch(v)) return '5 Digits';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
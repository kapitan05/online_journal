import 'dart:io';
import 'package:flutter/material.dart';

class ReviewStep extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String street;
  final String city;
  final String zip;
  final String? selectedImagePath;

  const ReviewStep({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.street,
    required this.city,
    required this.zip,
    this.selectedImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display selected image if any
          Center(
            child: CircleAvatar(
              radius: 30,
              backgroundImage: selectedImagePath != null
                  ? FileImage(File(selectedImagePath!))
                  : null,
              child: selectedImagePath == null ? const Icon(Icons.person) : null,
            ),
          ),
          const SizedBox(height: 10),
          _buildReviewRow('Name:', '$firstName $lastName'),
          _buildReviewRow('Email:', email),
          const Divider(),
          _buildReviewRow('Address:', street),
          _buildReviewRow('City:', '$city, $zip'),
          const SizedBox(height: 10),
          const Text('Please verify information before submitting.', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
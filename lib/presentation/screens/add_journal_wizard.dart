import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/journal_cubit.dart';

// Import the widgets
import 'package:online_journal_local/presentation/widgets/journal_wizard_steps/journal_basics_step.dart';
import 'package:online_journal_local/presentation/widgets/journal_wizard_steps/journal_content_step.dart';
import 'package:online_journal_local/presentation/widgets/journal_wizard_steps/journal_review_step.dart';

class AddJournalWizard extends StatefulWidget {
  final String userId;
  const AddJournalWizard({super.key, required this.userId});

  @override
  State<AddJournalWizard> createState() => _AddJournalWizardState();
}

class _AddJournalWizardState extends State<AddJournalWizard> {
  int _currentStep = 0;
  
  // Form Keys for validation
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  // State for Step 3
  String _selectedMood = 'Neutral';
  final List<String> _moods = ['Happy', 'Neutral', 'Sad', 'Excited', 'Tired'];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Logic to handle "Continue" button
  void _onStepContinue() {
    bool isLastStep = (_currentStep == 2); // 0, 1, 2 (Total 3 steps)

    if (isLastStep) {
      // FINAL STEP: Save Data
      context.read<JournalCubit>().addEntry(
        _titleController.text,
        _contentController.text,
        _selectedMood,
        widget.userId, // Pass the userId
      );
      Navigator.pop(context); // Close the wizard
    } else {
      // NORMAL STEP: Validate and Move Next
      bool isValid = false;
      if (_currentStep == 0) {
        isValid = _step1Key.currentState!.validate();
      } else if (_currentStep == 1) {
        isValid = _step2Key.currentState!.validate();
      }

      if (isValid) {
        setState(() {
          _currentStep += 1;
        });
      }
    }
  }

  // Logic to handle "Cancel/Back" button
  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    } else {
      Navigator.pop(context); // Close if back pressed on first step
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Journal Entry')),
      body: Stepper(
        type: StepperType.horizontal, // Shows steps in a row
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        // Customizing the button text for the final step
        controlsBuilder: (context, details) {
          final isLastStep = _currentStep == 2;
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: [
                FilledButton(
                  onPressed: details.onStepContinue,
                  child: Text(isLastStep ? 'FINISH & SAVE' : 'NEXT'),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: Text(isLastStep ? 'BACK' : 'CANCEL'),
                ),
              ],
            ),
          );
        },
        steps: [
          // STEP 1: Title
          Step(
            title: const Text('Basics'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.editing,
            content: JournalBasicsStep(
              formKey: _step1Key,
              titleController: _titleController,
            ),
          ),

          // STEP 2: Content
          Step(
            title: const Text('Thoughts'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.editing,
            content: JournalContentStep(
              formKey: _step2Key,
              contentController: _contentController,
            ),
          ),

          // STEP 3: Mood & Review
          Step(
            title: const Text('Review'),
            isActive: _currentStep >= 2,
            content: JournalReviewStep(
              selectedMood: _selectedMood,
              moods: _moods,
              title: _titleController.text,
              content: _contentController.text,
              onMoodChanged: (String? newValue) {
                setState(() {
                  _selectedMood = newValue!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
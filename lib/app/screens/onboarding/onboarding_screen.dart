import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/components/gradient_button.dart';
import '../../../core/design_system/components/hair_brand_app_bar.dart';
import '../../../core/design_system/persistence/onboarding_cubit.dart';
import '../../../core/entities/hair_type.dart';
import 'widgets/display_name_field.dart';
import 'widgets/hair_type_picker.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  HairType? _hairType;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty && _hairType != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HairBrandAppBar(
        title: 'Welcome to HairPredict',
        showBrandMark: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Let's personalize your hair journey",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Two quick questions and you\'re in.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Text(
                'What should we call you?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              DisplayNameField(controller: _nameController),
              const SizedBox(height: 32),
              Text(
                'What\'s your hair type?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              HairTypePicker(
                selected: _hairType,
                onChanged: (t) => setState(() => _hairType = t),
              ),
              const SizedBox(height: 32),
              GradientButton(
                label: 'Continue',
                isExpanded: true,
                onPressed: _isValid
                    ? () => context.read<OnboardingCubit>().complete(
                          _nameController.text.trim(),
                          _hairType!,
                        )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

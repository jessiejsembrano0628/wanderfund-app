import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  int _step = 0;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String _normalizeMobileNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final localNumber = digits.startsWith('63') ? digits.substring(2) : digits;
    return '+63$localNumber';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  String? _validateMobileNumber(String? value) {
    final mobileNumber = (value ?? '').replaceAll(RegExp(r'\D'), '');
    final localNumber = mobileNumber.startsWith('63')
        ? mobileNumber.substring(2)
        : mobileNumber;

    if (localNumber.isEmpty) return 'Mobile number is required';
    if (localNumber.length != 10 || !localNumber.startsWith('9')) {
      return 'Enter a valid Philippine mobile number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    final atIndex = email.indexOf('@');
    if (!EmailValidator.validate(email) ||
        atIndex <= 0 ||
        email.substring(0, atIndex).contains('+')) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validateStep() {
    if (_step == 0) {
      final firstNameError = _required(_firstNameController.text, 'First name');
      if (firstNameError != null) return firstNameError;
      final lastNameError = _required(_lastNameController.text, 'Last name');
      if (lastNameError != null) return lastNameError;
      return null;
    }

    if (_passwordController.text.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  bool _validateCurrentStep() {
    final fieldsValid = _formKey.currentState?.validate() ?? false;
    final error = _validateStep();
    if (error != null) {
      _showError(error);
      return false;
    }
    return fieldsValid;
  }

  void _nextStep() {
    if (!_validateCurrentStep()) return;
    setState(() => _step = 1);
  }

  Future<void> _submit() async {
    if (!_validateCurrentStep()) return;

    final success = await context.read<AuthProvider>().register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      mobileNumber: _normalizeMobileNumber(_mobileController.text),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful. Please log in.'),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _step == 0 ? 'Your details' : 'Login details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Step ${_step + 1} of 2'),
                  const SizedBox(height: 24),
                  if (_step == 0) ...[
                    _field(_firstNameController, 'First name', Icons.person),
                    const SizedBox(height: 16),
                    _field(
                      _lastNameController,
                      'Last name',
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _field(
                      _mobileController,
                      'Mobile number',
                      null,
                      keyboardType: TextInputType.phone,
                      prefixText: '+63',
                      validator: _validateMobileNumber,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                  ] else ...[
                    _field(
                      _emailController,
                      'Email',
                      Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 16),
                    _passwordField(
                      controller: _passwordController,
                      label: 'Password',
                      obscure: _obscurePassword,
                      onToggle: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    const SizedBox(height: 16),
                    _passwordField(
                      controller: _confirmPasswordController,
                      label: 'Confirm password',
                      obscure: _obscureConfirmPassword,
                      onToggle: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ],
                  if (authProvider.errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      authProvider.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      if (_step == 1)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : () => setState(() => _step = 0),
                            child: const Text('Back'),
                          ),
                        ),
                      if (_step == 1) const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : (_step == 0 ? _nextStep : _submit),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(_step == 0 ? 'Next' : 'Register'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData? icon, {
    TextInputType? keyboardType,
    String? prefixText,
    String? Function(String?)? validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      key: ValueKey(label),
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      autovalidateMode: autovalidateMode,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
        prefixText: prefixText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

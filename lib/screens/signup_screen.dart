import 'package:flutter/material.dart';

import '../services/profile_storage.dart';
import 'success_screen.dart';

enum TipStatus { idle, loading, success }

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const _creatureTypes = [
    'Ghost',
    'Bat',
    'Black Cat',
    'Pumpkin Spirit',
    'Witch',
  ];
  static const _presetTips = [
    'Use a long, unique passphrase that you do not reuse elsewhere.',
    'A password manager can create and store a different password for every account.',
    'Combine several unrelated words into a memorable passphrase.',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dateController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  DateTime? _birthDate;
  String? _selectedCreatureType;
  TipStatus _tipStatus = TipStatus.idle;
  String? _tip;
  int _nextTipIndex = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Please enter your email';
    if (!email.contains('@')) return 'Please enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 18, now.month, now.day);
    final chosenDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (chosenDate == null || !mounted) return;

    setState(() {
      _birthDate = chosenDate;
      final month = chosenDate.month.toString().padLeft(2, '0');
      final day = chosenDate.day.toString().padLeft(2, '0');
      _dateController.text = '$month/$day/${chosenDate.year}';
    });
  }

  Future<void> _loadPresetTip() async {
    setState(() {
      _tipStatus = TipStatus.loading;
      _tip = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _tip = _presetTips[_nextTipIndex % _presetTips.length];
      _nextTipIndex++;
      _tipStatus = TipStatus.success;
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final firstName = _nameController.text.trim().split(RegExp(r'\s+')).first;
    await ProfileStorage.save(
      firstName: firstName,
      birthDate: _birthDate!,
      creatureType: _selectedCreatureType!,
    );
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SuccessScreen(
          userName: firstName,
          creatureType: _selectedCreatureType!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enchanted Signup Laboratory'),
        backgroundColor: const Color(0xFF2E1065),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '🧪',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 52),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your haunted guest profile',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  key: const Key('nameField'),
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('emailField'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('passwordField'),
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      key: const Key('passwordVisibilityButton'),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('birthDateField'),
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickBirthDate,
                  decoration: const InputDecoration(
                    labelText: 'Birth Date',
                    prefixIcon: Icon(Icons.cake),
                  ),
                  validator: (_) =>
                      _birthDate == null ? 'Please pick your birth date' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: const Key('creatureDropdown'),
                  initialValue: _selectedCreatureType,
                  decoration: const InputDecoration(
                    labelText: 'Creature Type',
                    prefixIcon: Icon(Icons.pets),
                  ),
                  items: _creatureTypes
                      .map(
                        (creature) => DropdownMenuItem(
                          value: creature,
                          child: Text(creature),
                        ),
                      )
                      .toList(),
                  onChanged: _isSubmitting
                      ? null
                      : (value) =>
                            setState(() => _selectedCreatureType = value),
                  validator: (value) =>
                      value == null ? 'Please choose a creature type' : null,
                ),
                const SizedBox(height: 18),
                ExpansionTile(
                  key: const Key('localCoachTile'),
                  title: const Text('Local signup coach'),
                  subtitle: const Text('Preset guidance — no form data used'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton.icon(
                            key: const Key('tipButton'),
                            onPressed: _tipStatus == TipStatus.loading
                                ? null
                                : _loadPresetTip,
                            icon: const Icon(Icons.lightbulb_outline),
                            label: const Text('Get a signup tip'),
                          ),
                          if (_tipStatus == TipStatus.loading)
                            const Padding(
                              padding: EdgeInsets.all(12),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          if (_tipStatus == TipStatus.success && _tip != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Preset demo tip—not live AI.\n$_tip',
                                key: const Key('tipResult'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  key: const Key('signupButton'),
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    _isSubmitting
                        ? 'Opening the ballroom…'
                        : 'Register Creature',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import '../services/profile_storage.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  SavedGuestProfile? _savedProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileStorage.load();
    if (!mounted) return;
    setState(() {
      _savedProfile = profile;
      _isLoadingProfile = false;
    });
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E1065), Color(0xFF0F0718)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🦇', style: TextStyle(fontSize: 78)),
                  const SizedBox(height: 12),
                  AnimatedTextKit(
                    key: const Key('animatedTitle'),
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'The Haunted Creature Registry',
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        speed: const Duration(milliseconds: 70),
                      ),
                    ],
                    totalRepeatCount: 1,
                    displayFullTextOnTap: true,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Register your creature companion… if you dare.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 28),
                  if (_isLoadingProfile)
                    const CircularProgressIndicator(
                      key: Key('profileLoadingIndicator'),
                    )
                  else if (_savedProfile != null)
                    Card(
                      key: const Key('returningGuestCard'),
                      color: const Color(0xFF3B1B5A),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            Text(
                              'Welcome back, ${_savedProfile!.firstName}!',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Your ${_savedProfile!.creatureType} is registered.\n'
                              'Birth date on file: ${_formatDate(_savedProfile!.birthDate)}',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const Text(
                      'No returning guest profile found.',
                      key: Key('freshInstallMessage'),
                      style: TextStyle(color: Colors.white60),
                    ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    key: const Key('enterRegistryButton'),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const SignupScreen(),
                        ),
                      );
                      await _loadProfile();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFEA580C),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 16,
                      ),
                    ),
                    icon: const Icon(Icons.door_front_door),
                    label: const Text('Enter If You Dare'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

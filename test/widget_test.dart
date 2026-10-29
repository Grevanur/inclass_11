import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haunted_creature_registry/main.dart';
import 'package:haunted_creature_registry/services/profile_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> openSignup(WidgetTester tester) async {
    await tester.pumpWidget(const HauntedMansionApp());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const Key('enterRegistryButton')));
    await tester.pumpAndSettle();
  }

  testWidgets('fresh install starts in the foyer and opens the laboratory', (
    tester,
  ) async {
    await tester.pumpWidget(const HauntedMansionApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('freshInstallMessage')), findsOneWidget);
    expect(find.text('Enter If You Dare'), findsOneWidget);

    await tester.tap(find.byKey(const Key('enterRegistryButton')));
    await tester.pumpAndSettle();

    expect(find.text('Enchanted Signup Laboratory'), findsOneWidget);
  });

  testWidgets('empty form preserves validators and requires new fields', (
    tester,
  ) async {
    await openSignup(tester);
    final button = find.byKey(const Key('signupButton'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();

    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter a password'), findsOneWidget);
    expect(find.text('Please pick your birth date'), findsOneWidget);
    expect(find.text('Please choose a creature type'), findsOneWidget);
  });

  testWidgets('password visibility toggle changes obscure state', (
    tester,
  ) async {
    await openSignup(tester);
    EditableText passwordInput = tester.widget(
      find.descendant(
        of: find.byKey(const Key('passwordField')),
        matching: find.byType(EditableText),
      ),
    );
    expect(passwordInput.obscureText, isTrue);

    await tester.tap(find.byKey(const Key('passwordVisibilityButton')));
    await tester.pump();

    passwordInput = tester.widget(
      find.descendant(
        of: find.byKey(const Key('passwordField')),
        matching: find.byType(EditableText),
      ),
    );
    expect(passwordInput.obscureText, isFalse);
  });

  testWidgets('valid registration reaches personalized ballroom', (
    tester,
  ) async {
    await openSignup(tester);
    await tester.enterText(
      find.byKey(const Key('nameField')),
      'Gowtham Revanur',
    );
    await tester.enterText(
      find.byKey(const Key('emailField')),
      'gowtham@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('passwordField')),
      'haunted123',
    );

    await tester.tap(find.byKey(const Key('birthDateField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('creatureDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ghost').last);
    await tester.pumpAndSettle();

    final button = find.byKey(const Key('signupButton'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();

    expect(find.text('Opening the ballroom…'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Welcome, Gowtham!'), findsOneWidget);
    expect(
      find.text('Your Ghost companion has joined the registry.'),
      findsOneWidget,
    );
  });

  testWidgets('returning guest profile appears after app relaunch', (
    tester,
  ) async {
    await ProfileStorage.save(
      firstName: 'Gowtham',
      birthDate: DateTime(2000, 10, 31),
      creatureType: 'Black Cat',
    );

    await tester.pumpWidget(const HauntedMansionApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Welcome back, Gowtham!'), findsOneWidget);
    expect(find.textContaining('Black Cat'), findsOneWidget);
    expect(find.textContaining('10/31/2000'), findsOneWidget);
  });

  test('storage saves required profile data and excludes password', () async {
    await ProfileStorage.save(
      firstName: 'Gowtham',
      birthDate: DateTime(2000, 10, 31),
      creatureType: 'Witch',
    );

    final profile = await ProfileStorage.load();
    final preferences = await SharedPreferences.getInstance();

    expect(profile?.firstName, 'Gowtham');
    expect(profile?.birthDate, DateTime(2000, 10, 31));
    expect(profile?.creatureType, 'Witch');
    expect(
      preferences.getKeys().any(
        (key) => key.toLowerCase().contains('password'),
      ),
      isFalse,
    );
  });
}

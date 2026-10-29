import 'package:shared_preferences/shared_preferences.dart';

class SavedGuestProfile {
  const SavedGuestProfile({
    required this.firstName,
    required this.birthDate,
    required this.creatureType,
  });

  final String firstName;
  final DateTime birthDate;
  final String creatureType;
}

class ProfileStorage {
  static const _firstNameKey = 'guest_first_name';
  static const _birthDateKey = 'guest_birth_date';
  static const _creatureTypeKey = 'guest_creature_type';

  static Future<void> save({
    required String firstName,
    required DateTime birthDate,
    required String creatureType,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setString(_firstNameKey, firstName),
      preferences.setString(_birthDateKey, birthDate.toIso8601String()),
      preferences.setString(_creatureTypeKey, creatureType),
    ]);
  }

  static Future<SavedGuestProfile?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final firstName = preferences.getString(_firstNameKey);
    final birthDateText = preferences.getString(_birthDateKey);
    final creatureType = preferences.getString(_creatureTypeKey);
    final birthDate = birthDateText == null
        ? null
        : DateTime.tryParse(birthDateText);

    if (firstName == null ||
        firstName.trim().isEmpty ||
        birthDate == null ||
        creatureType == null ||
        creatureType.trim().isEmpty) {
      return null;
    }

    return SavedGuestProfile(
      firstName: firstName,
      birthDate: birthDate,
      creatureType: creatureType,
    );
  }
}

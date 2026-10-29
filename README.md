# The Haunted Creature Registry

MAD 4360 In Class Activity 11 graduate track implementation. This project extends the validated Activity 10 signup form into a three screen Flutter app and completes exactly one graduate extension: Task B, The Mansion Remembers.

## Student and group information

- Student: Gowtham Revanur
- Confirmed partner from Activity 10: Swamireddy Ailuri
- Remaining group member names: add only if they actually participated
- Repository: https://github.com/Grevanur/inclass_11
- Track: Graduate
- Extension: Task B, The Mansion Remembers

## Shared build

- `WelcomeScreen` provides the animated foyer and uses `Navigator.push` so Back from the laboratory returns to the foyer.
- `SignupScreen` preserves the Activity 10 name, email, and password validators.
- The form adds a required creature dropdown, password visibility toggle, birth date picker, loading state, and the existing local preset signup coach.
- A valid form uses `Navigator.pushReplacement` to reach a personalized `SuccessScreen` with confetti.
- `SuccessScreen` blocks Back so a completed signup cannot expose or resubmit the password form.
- `main.dart` contains only the app shell and initial route.

## Graduate Task B storage policy

The app stores only the guest's first name, ISO formatted birth date, and selected creature type in `shared_preferences`. It loads all three values when the foyer starts and displays a returning guest greeting only when the complete saved profile is valid. A fresh install displays no returning greeting.

The password is never stored. If an attacker obtained an unencrypted preferences backup from a compromised or debug enabled device, a stored password could be reused against this or another account. Keeping the password out of preferences limits that exposure. Email is also excluded because Task B does not require it for the returning greeting.

## Task B acceptance table

| Case | Expected behavior | Automated observation |
| --- | --- | --- |
| Fresh install | No returning guest greeting | Passed: `freshInstallMessage` is shown with empty mocked preferences |
| Successful signup | First name, birth date, and creature type are saved | Passed: storage test reloads all three exact values |
| Relaunch with saved profile | Foyer greets the guest and identifies the creature | Passed: widget test shows `Welcome back, Gowtham!`, `Black Cat`, and `10/31/2000` |
| Password exclusion | No password key or value is persisted | Passed: preferences key inspection contains no password key |
| Shared flow | Welcome to Signup to Success carries name and creature | Passed: widget test reaches `Welcome, Gowtham!` and the Ghost confirmation |

Android emulator evidence confirms the same behavior: a fresh install showed no greeting, registration reached the personalized Black Cat success screen, and a force stop plus relaunch restored Gowtham, the Black Cat selection, and the saved birth date.

## Engineering trade off and improvement

`shared_preferences` is appropriate for three small nonsecret values and keeps the returning greeting simple. Its limitation is that it is not encrypted or suitable for credentials, which is why the app deliberately excludes the password. A future improvement would add an explicit clear profile action and use a typed local data layer if the profile grows beyond these three fields.

## Verification status

- `flutter analyze`: passed with no issues
- `flutter test`: six tests passed
- `flutter build apk --release`: passed
- Android emulator: release APK installed and verified through fresh install, registration, force stop, and relaunch
- Evidence: `evidence/task_b_fresh_install.png`, `evidence/activity11_success.png`, and `evidence/activity11_relaunch.png`

## AI assistance disclosure

The instructor message supplied by Gowtham Revanur states that Gowtham may use AI assistants to help with coding because of limited availability. AI assistance was used for implementation, automated tests, documentation structure, and packaging. Emulator observations, group contribution claims, and any live explanation must be completed and verified by the students themselves.

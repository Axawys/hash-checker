// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Hash Checker';

  @override
  String get selectFileForCheckDialog => 'Select file to check';

  @override
  String get selectHashFileDialog => 'Select hash file';

  @override
  String get invalidHashFormat => 'Invalid hash format';

  @override
  String get readFileError => 'File read error';

  @override
  String get openFileDialogError => 'Could not open the system file picker.';

  @override
  String get fromClipboard => 'From clipboard';

  @override
  String algorithmChanged(String algorithm) {
    return 'Algorithm changed to $algorithm';
  }

  @override
  String get hashesMatchTitle => 'Hashes match';

  @override
  String hashesMatchDescription(String algorithm) {
    return 'Data integrity confirmed ($algorithm)';
  }

  @override
  String get hashesDifferTitle => 'Hashes differ!';

  @override
  String get hashesDifferDescription => 'The data does not match the reference';

  @override
  String get chooseFilePlaceholder => 'Choose a file...';

  @override
  String hashingStatus(String algorithm) {
    return 'Calculating $algorithm...';
  }

  @override
  String get hashReferencePlaceholder => 'File or paste (sha256:...)';

  @override
  String get settingsSection => 'Settings';

  @override
  String get hashAlgorithmLabel => 'Hash algorithm';

  @override
  String get verificationDataSection => 'Verification data';

  @override
  String get fileForCheckTitle => 'File to check';

  @override
  String get chooseFileTooltip => 'Choose file';

  @override
  String get referenceHashTitle => 'Reference hash';

  @override
  String get pasteFromClipboardTooltip => 'Paste from clipboard';

  @override
  String get chooseHashFileTooltip => 'Choose hash file';

  @override
  String get verifyButton => 'Compare hashes';
}

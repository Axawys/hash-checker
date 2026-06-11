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
  String get manualHashSource => 'Entered manually';

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

  @override
  String get helpTooltip => 'Help';

  @override
  String get helpTitle => 'How to use';

  @override
  String get helpOverview =>
      'HashChecker helps verify whether the selected file hash matches a trusted reference hash.';

  @override
  String get helpStepsTitle => 'Basic workflow';

  @override
  String get helpStepChooseFile =>
      'Choose the file to check with the folder button or drop it onto the file area.';

  @override
  String get helpStepReferenceHash =>
      'Enter the reference hash manually, paste it from the clipboard, or choose a file that contains the hash.';

  @override
  String get helpStepAlgorithm =>
      'When the algorithm can be detected from the reference hash, the app selects it automatically. You can also choose it manually.';

  @override
  String get helpStepCompare =>
      'After calculation, press the compare button to see the verification result.';

  @override
  String get helpFeaturesTitle => 'Features';

  @override
  String get helpFeatureDragDrop =>
      'Files can be added with drag and drop: one area for the checked file and one for the reference hash file.';

  @override
  String get helpFeatureProgress =>
      'Progress and estimated remaining time are shown during calculation.';

  @override
  String get helpFeatureCopyHash =>
      'The calculated hash is shown in full and can be selected or copied with a button.';

  @override
  String get closeButton => 'Close';

  @override
  String get calculatedHashTitle => 'Calculated hash';

  @override
  String get copyHashTooltip => 'Copy hash';

  @override
  String get hashCopied => 'Hash copied';

  @override
  String hashProgress(int percent, String time) {
    return '$percent% · about $time remaining';
  }

  @override
  String get dropFileForCheck => 'Drop file here';

  @override
  String get dropHashFile => 'Drop hash file here';

  @override
  String get lessThanSecond => 'less than 1 sec.';

  @override
  String secondsShort(int seconds) {
    return '$seconds sec.';
  }

  @override
  String minutesSecondsShort(int minutes, int seconds) {
    return '$minutes min. $seconds sec.';
  }
}

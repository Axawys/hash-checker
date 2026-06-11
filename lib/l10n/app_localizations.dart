import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Hash Checker'**
  String get appTitle;

  /// No description provided for @selectFileForCheckDialog.
  ///
  /// In en, this message translates to:
  /// **'Select file to check'**
  String get selectFileForCheckDialog;

  /// No description provided for @selectHashFileDialog.
  ///
  /// In en, this message translates to:
  /// **'Select hash file'**
  String get selectHashFileDialog;

  /// No description provided for @invalidHashFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid hash format'**
  String get invalidHashFormat;

  /// No description provided for @readFileError.
  ///
  /// In en, this message translates to:
  /// **'File read error'**
  String get readFileError;

  /// No description provided for @openFileDialogError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the system file picker.'**
  String get openFileDialogError;

  /// No description provided for @fromClipboard.
  ///
  /// In en, this message translates to:
  /// **'From clipboard'**
  String get fromClipboard;

  /// No description provided for @manualHashSource.
  ///
  /// In en, this message translates to:
  /// **'Entered manually'**
  String get manualHashSource;

  /// No description provided for @algorithmChanged.
  ///
  /// In en, this message translates to:
  /// **'Algorithm changed to {algorithm}'**
  String algorithmChanged(String algorithm);

  /// No description provided for @hashesMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Hashes match'**
  String get hashesMatchTitle;

  /// No description provided for @hashesMatchDescription.
  ///
  /// In en, this message translates to:
  /// **'Data integrity confirmed ({algorithm})'**
  String hashesMatchDescription(String algorithm);

  /// No description provided for @hashesDifferTitle.
  ///
  /// In en, this message translates to:
  /// **'Hashes differ!'**
  String get hashesDifferTitle;

  /// No description provided for @hashesDifferDescription.
  ///
  /// In en, this message translates to:
  /// **'The data does not match the reference'**
  String get hashesDifferDescription;

  /// No description provided for @chooseFilePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Choose a file...'**
  String get chooseFilePlaceholder;

  /// No description provided for @hashingStatus.
  ///
  /// In en, this message translates to:
  /// **'Calculating {algorithm}...'**
  String hashingStatus(String algorithm);

  /// No description provided for @hashReferencePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'File or paste (sha256:...)'**
  String get hashReferencePlaceholder;

  /// No description provided for @settingsSection.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsSection;

  /// No description provided for @hashAlgorithmLabel.
  ///
  /// In en, this message translates to:
  /// **'Hash algorithm'**
  String get hashAlgorithmLabel;

  /// No description provided for @verificationDataSection.
  ///
  /// In en, this message translates to:
  /// **'Verification data'**
  String get verificationDataSection;

  /// No description provided for @fileForCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'File to check'**
  String get fileForCheckTitle;

  /// No description provided for @chooseFileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get chooseFileTooltip;

  /// No description provided for @referenceHashTitle.
  ///
  /// In en, this message translates to:
  /// **'Reference hash'**
  String get referenceHashTitle;

  /// No description provided for @pasteFromClipboardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get pasteFromClipboardTooltip;

  /// No description provided for @chooseHashFileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Choose hash file'**
  String get chooseHashFileTooltip;

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Compare hashes'**
  String get verifyButton;

  /// No description provided for @helpTooltip.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTooltip;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'How to use'**
  String get helpTitle;

  /// No description provided for @helpOverview.
  ///
  /// In en, this message translates to:
  /// **'HashChecker helps verify whether the selected file hash matches a trusted reference hash.'**
  String get helpOverview;

  /// No description provided for @helpStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic workflow'**
  String get helpStepsTitle;

  /// No description provided for @helpStepChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose the file to check with the folder button or drop it onto the file area.'**
  String get helpStepChooseFile;

  /// No description provided for @helpStepReferenceHash.
  ///
  /// In en, this message translates to:
  /// **'Enter the reference hash manually, paste it from the clipboard, or choose a file that contains the hash.'**
  String get helpStepReferenceHash;

  /// No description provided for @helpStepAlgorithm.
  ///
  /// In en, this message translates to:
  /// **'When the algorithm can be detected from the reference hash, the app selects it automatically. You can also choose it manually.'**
  String get helpStepAlgorithm;

  /// No description provided for @helpStepCompare.
  ///
  /// In en, this message translates to:
  /// **'After calculation, press the compare button to see the verification result.'**
  String get helpStepCompare;

  /// No description provided for @helpFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get helpFeaturesTitle;

  /// No description provided for @helpFeatureDragDrop.
  ///
  /// In en, this message translates to:
  /// **'Files can be added with drag and drop: one area for the checked file and one for the reference hash file.'**
  String get helpFeatureDragDrop;

  /// No description provided for @helpFeatureProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress and estimated remaining time are shown during calculation.'**
  String get helpFeatureProgress;

  /// No description provided for @helpFeatureCopyHash.
  ///
  /// In en, this message translates to:
  /// **'The calculated hash is shown in full and can be selected or copied with a button.'**
  String get helpFeatureCopyHash;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @calculatedHashTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculated hash'**
  String get calculatedHashTitle;

  /// No description provided for @copyHashTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy hash'**
  String get copyHashTooltip;

  /// No description provided for @hashCopied.
  ///
  /// In en, this message translates to:
  /// **'Hash copied'**
  String get hashCopied;

  /// No description provided for @hashProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}% · about {time} remaining'**
  String hashProgress(int percent, String time);

  /// No description provided for @dropFileForCheck.
  ///
  /// In en, this message translates to:
  /// **'Drop file here'**
  String get dropFileForCheck;

  /// No description provided for @dropHashFile.
  ///
  /// In en, this message translates to:
  /// **'Drop hash file here'**
  String get dropHashFile;

  /// No description provided for @lessThanSecond.
  ///
  /// In en, this message translates to:
  /// **'less than 1 sec.'**
  String get lessThanSecond;

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'{seconds} sec.'**
  String secondsShort(int seconds);

  /// No description provided for @minutesSecondsShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min. {seconds} sec.'**
  String minutesSecondsShort(int minutes, int seconds);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

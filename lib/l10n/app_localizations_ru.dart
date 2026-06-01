// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Hash Checker';

  @override
  String get selectFileForCheckDialog => 'Выберите файл для проверки';

  @override
  String get selectHashFileDialog => 'Выберите файл с хешем';

  @override
  String get invalidHashFormat => 'Неверный формат хеша';

  @override
  String get readFileError => 'Ошибка чтения файла';

  @override
  String get openFileDialogError =>
      'Не удалось открыть системный диалог выбора файла.';

  @override
  String get fromClipboard => 'Из буфера';

  @override
  String algorithmChanged(String algorithm) {
    return 'Алгоритм изменен на $algorithm';
  }

  @override
  String get hashesMatchTitle => 'Суммы совпали';

  @override
  String hashesMatchDescription(String algorithm) {
    return 'Целостность данных подтверждена ($algorithm)';
  }

  @override
  String get hashesDifferTitle => 'Суммы различаются!';

  @override
  String get hashesDifferDescription => 'Данные не совпадают с эталоном';

  @override
  String get chooseFilePlaceholder => 'Выберите файл...';

  @override
  String hashingStatus(String algorithm) {
    return 'Вычисляю $algorithm...';
  }

  @override
  String get hashReferencePlaceholder => 'Файл или вставка (sha256:...)';

  @override
  String get settingsSection => 'Настройки';

  @override
  String get hashAlgorithmLabel => 'Алгоритм хеширования';

  @override
  String get verificationDataSection => 'Данные для сверки';

  @override
  String get fileForCheckTitle => 'Файл для проверки';

  @override
  String get chooseFileTooltip => 'Выбрать файл';

  @override
  String get referenceHashTitle => 'Эталонный хеш';

  @override
  String get pasteFromClipboardTooltip => 'Вставить из буфера';

  @override
  String get chooseHashFileTooltip => 'Выбрать файл с хешем';

  @override
  String get verifyButton => 'Сверить хеш-суммы';
}

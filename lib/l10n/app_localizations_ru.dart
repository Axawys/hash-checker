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
  String get manualHashSource => 'Введено вручную';

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

  @override
  String get helpTooltip => 'Справка';

  @override
  String get helpTitle => 'Как пользоваться';

  @override
  String get helpOverview =>
      'HashChecker помогает проверить, совпадает ли хеш выбранного файла с эталонной суммой.';

  @override
  String get helpStepsTitle => 'Основной порядок';

  @override
  String get helpStepChooseFile =>
      'Выберите файл для проверки кнопкой с папкой или перетащите его в область файла.';

  @override
  String get helpStepReferenceHash =>
      'Введите эталонный хеш вручную, вставьте его из буфера обмена или выберите файл с хеш-суммой.';

  @override
  String get helpStepAlgorithm =>
      'Если алгоритм можно определить по эталонному хешу, приложение выберет его автоматически. Также алгоритм можно выбрать вручную.';

  @override
  String get helpStepCompare =>
      'После расчета нажмите кнопку сверки, чтобы увидеть результат проверки.';

  @override
  String get helpFeaturesTitle => 'Возможности';

  @override
  String get helpFeatureDragDrop =>
      'Файлы можно добавлять перетаскиванием: отдельно файл для проверки и отдельно файл с эталонным хешем.';

  @override
  String get helpFeatureProgress =>
      'Во время расчета показываются прогресс и примерное оставшееся время.';

  @override
  String get helpFeatureCopyHash =>
      'Рассчитанный хеш отображается полностью, его можно выделить или скопировать кнопкой.';

  @override
  String get closeButton => 'Закрыть';

  @override
  String get calculatedHashTitle => 'Рассчитанный хеш';

  @override
  String get copyHashTooltip => 'Скопировать хеш';

  @override
  String get hashCopied => 'Хеш скопирован';

  @override
  String hashProgress(int percent, String time) {
    return '$percent% · осталось примерно $time';
  }

  @override
  String get dropFileForCheck => 'Перетащите файл сюда';

  @override
  String get dropHashFile => 'Перетащите файл с хешем сюда';

  @override
  String get lessThanSecond => 'меньше 1 сек.';

  @override
  String secondsShort(int seconds) {
    return '$seconds сек.';
  }

  @override
  String minutesSecondsShort(int minutes, int seconds) {
    return '$minutes мин. $seconds сек.';
  }
}

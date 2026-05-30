# HashChecker

<p align="center">
  <img src="assets/icon.png" width="128" alt="HashChecker icon">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/license-MIT-blue" alt="License MIT">
  <img src="https://img.shields.io/badge/platform-windows%20%7C%20linux-lightgrey" alt="Platform">
  <img src="https://img.shields.io/badge/dart-%230175C2.svg?style=flat&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/flutter-%2302569B.svg?style=flat&logo=flutter&logoColor=white" alt="Flutter Logo">
</p>

Кроссплатформенная утилита для проверки контрольных сумм файлов.  
Поддерживает MD5, SHA-1, SHA-256, SHA-512.

## О проекте

Изначально проект был написан на Python + GTK4 (только для Linux).  
Начиная с версии 2.0.0 полностью переписан на Flutter.

Это дало:
- единый код для всех платформ
- поддержку Windows и Linux
- упрощение разработки и поддержки

## Скачать

Актуальные сборки доступны во вкладке Releases.

Windows:
- HashChecker-Setup.exe

Linux:
- hashchecker-2.0.0-1.x86_64.rpm

## Возможности

- Проверка хеш-сумм:
  - MD5
  - SHA-1
  - SHA-256
  - SHA-512
- Автоматическое определение алгоритма
- Вставка из буфера обмена
- Простой интерфейс

## Скриншоты

![screenshot1](assets/screenshots/pic1.png)  
![screenshot2](assets/screenshots/pic2.png)  
![screenshot3](assets/screenshots/pic3.png)

## Сборка из исходников

Требования:
- Flutter SDK

Установка:
https://docs.flutter.dev/get-started/install

### Запуск

```bash
flutter pub get
flutter run -d linux
```

### Сборка Linux

```bash
flutter build linux --release
```

Готовый bundle будет создан в:

```text
build/linux/x64/release/bundle/
```

Для RPM-релиза используется `fpm`. Пример упаковки:

```bash
fpm -s dir -t rpm \
  -n hashchecker \
  -v 2.0.0 \
  --iteration 1 \
  -a x86_64 \
  --description "File hash checker" \
  --url https://github.com/Axawys/hash-checker \
  --license MIT \
  --maintainer Axawys \
  --depends gtk3 \
  -C /path/to/package-root \
  -p dist/hashchecker-2.0.0-1.x86_64.rpm \
  .
```

### Сборка Windows

```bash
flutter build windows
```

После этого можно собрать установщик через Inno Setup:

```powershell
& "C:\Users\ВАШЕ_ИМЯ_ПОЛЬЗОВАТЕЛЯ\AppData\Local\Programs\Inno Setup 6\ISCC.exe" .\installer.iss
```

## Структура проекта

```text
lib/main.dart  — точка входа
lib/core/      — логика хеширования, парсинг эталона, утилиты
lib/ui/        — Flutter-интерфейс
windows/       — Windows runner
linux/         — Linux runner
assets/        — ресурсы
packaging/     — файлы упаковки
```

## Планы

- Улучшить UI
    
- Поддержка drag & drop
    
- CLI-режим
    

## Лицензия

Проект распространяется под лицензией MIT.  
Подробнее см. файл [LICENSE](LICENSE).

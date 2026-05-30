import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/hash_algorithms.dart';
import '../core/hash_reference.dart';
import '../core/hash_service.dart';
import '../core/path_utils.dart';

class HashCheckerPage extends StatefulWidget {
  const HashCheckerPage({super.key});

  @override
  State<HashCheckerPage> createState() => _HashCheckerPageState();
}

class _HashCheckerPageState extends State<HashCheckerPage> {
  final HashService hashService = const HashService();
  final List<String> availableAlgos = supportedHashAlgorithms;

  String selectedAlgo = 'SHA-256';

  String? filePath;
  String? hashPath;
  String? manualHash;
  String? calculatedHash;

  bool isHashing = false;
  bool fileDone = false;
  bool isDialogOpen = false;

  ResultState resultState = ResultState.hidden;
  String resultTitle = '';
  String resultDescription = '';

  bool get canVerify {
    final hasRef = (manualHash?.isNotEmpty ?? false) || (hashPath?.isNotEmpty ?? false);
    return filePath != null && calculatedHash != null && hasRef;
  }

  void showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  Future<void> pickFileForCheck() async {
    if (isDialogOpen) return;
    isDialogOpen = true;
    try {
      final result = await pickSingleFile('Выберите файл для проверки');
      if (result != null) {
        filePath = result.path;
        await startHashing(filePath!);
      }
    } finally {
      isDialogOpen = false;
    }
  }

  Future<void> pickHashFile() async {
    if (isDialogOpen) return;
    isDialogOpen = true;
    try {
      final result = await pickSingleFile('Выберите файл с хешем');
      if (result != null) {
        hashPath = result.path;
        try {
          final content = await hashService.readTextFile(hashPath!);
          final ok = processHashInput(content.trim(), basename(hashPath!));
          if (!ok) {
            setState(() {
              manualHash = null;
              resultState = ResultState.hidden;
            });
          }
        } catch (_) {
          showToast('Ошибка чтения файла');
        }
      }
    } finally {
      isDialogOpen = false;
    }
  }

  Future<XFile?> pickSingleFile(String confirmButtonText) async {
    try {
      return await openFile(confirmButtonText: confirmButtonText);
    } catch (_) {
      showToast('Не удалось открыть системный диалог выбора файла.');
      return null;
    }
  }

  Future<void> pasteHash() async {
    final text = await Clipboard.getData(Clipboard.kTextPlain);
    final ok = processHashInput(text?.text, 'Из буфера');
    if (!ok) {
      showToast('Неверный формат хеша');
    }
  }

  bool processHashInput(String? rawText, String sourceDisplayName) {
    final reference = parseHashReference(rawText, sourceDisplayName);
    if (reference == null) return false;

    String? toastMessage;
    if (reference.detectedAlgorithm != null && selectedAlgo != reference.detectedAlgorithm) {
      selectedAlgo = reference.detectedAlgorithm!;
      toastMessage = 'Алгоритм изменен на ${reference.detectedAlgorithm}';
    }

    setState(() {
      manualHash = reference.hash;
      resultState = ResultState.hidden;
      _hashSubtitleOverride = reference.subtitle;
    });

    if (toastMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showToast(toastMessage!));
    }

    if (filePath != null) {
      unawaited(startHashing(filePath!));
    }

    return true;
  }

  Future<void> startHashing(String path) async {
    final algo = selectedAlgo;

    setState(() {
      calculatedHash = null;
      isHashing = true;
      fileDone = false;
      resultState = ResultState.hidden;
    });

    try {
      final result = await hashService.computeFileHash(path, algo);

      if (!mounted) return;
      if (path != filePath || algo != selectedAlgo) return;

      setState(() {
        calculatedHash = result;
        isHashing = false;
        fileDone = true;
      });
    } catch (_) {
      if (!mounted) return;
      if (path != filePath) return;

      setState(() {
        isHashing = false;
        fileDone = false;
      });
      showToast('Ошибка чтения файла');
    }
  }

  Future<void> verifyHashes() async {
    String? expected = manualHash;

    if ((expected == null || expected.isEmpty) && hashPath != null) {
      try {
        final content = await hashService.readTextFile(hashPath!);
        expected = parseHashReference(content, basename(hashPath!))?.hash;
      } catch (_) {
        showToast('Ошибка чтения файла');
        return;
      }
    }

    if (expected == null || expected.isEmpty || calculatedHash == null) {
      return;
    }

    setState(() {
      if (hashService.hashesMatch(calculatedHash!, expected!)) {
        resultState = ResultState.success;
        resultTitle = 'Суммы совпали';
        resultDescription = 'Целостность данных подтверждена ($selectedAlgo)';
      } else {
        resultState = ResultState.error;
        resultTitle = 'Суммы различаются!';
        resultDescription = 'Данные не совпадают с эталоном';
      }
    });
  }

  String? _hashSubtitleOverride;

  String get fileSubtitle {
    if (filePath == null) return 'Выберите файл...';
    if (isHashing) return 'Вычисляю $selectedAlgo...';
    return basename(filePath!);
  }

  String get hashSubtitle {
    if (_hashSubtitleOverride != null) return _hashSubtitleOverride!;
    return 'Файл или вставка (sha256:...)';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hash Checker'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionCard(
                    title: 'Настройки',
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedAlgo,
                      decoration: const InputDecoration(
                        labelText: 'Алгоритм хеширования',
                        border: OutlineInputBorder(),
                      ),
                      items: availableAlgos
                          .map((algo) => DropdownMenuItem(value: algo, child: Text(algo)))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          selectedAlgo = value;
                        });
                        if (filePath != null) {
                          unawaited(startHashing(filePath!));
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'Данные для сверки',
                    child: Column(
                      children: [
                        _ActionTile(
                          icon: Icons.insert_drive_file_outlined,
                          title: 'Файл для проверки',
                          subtitle: fileSubtitle,
                          trailing: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: isHashing
                                    ? const CircularProgressIndicator(strokeWidth: 2)
                                    : const SizedBox.shrink(),
                              ),
                              if (fileDone)
                                Icon(Icons.check_circle, color: scheme.primary),
                              IconButton(
                                tooltip: 'Выбрать файл',
                                onPressed: pickFileForCheck,
                                icon: const Icon(Icons.folder_open),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ActionTile(
                          icon: Icons.paste_outlined,
                          title: 'Эталонный хеш',
                          subtitle: hashSubtitle,
                          trailing: Wrap(
                            spacing: 4,
                            children: [
                              IconButton(
                                tooltip: 'Вставить из буфера',
                                onPressed: pasteHash,
                                icon: const Icon(Icons.content_paste),
                              ),
                              IconButton(
                                tooltip: 'Выбрать файл с хешем',
                                onPressed: pickHashFile,
                                icon: const Icon(Icons.folder_open),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: FilledButton(
                      onPressed: canVerify ? verifyHashes : null,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(220, 48),
                      ),
                      child: const Text('Сверить хеш-суммы'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (resultState != ResultState.hidden)
                    _ResultCard(
                      state: resultState,
                      title: resultTitle,
                      description: resultDescription,
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

enum ResultState { hidden, success, error }

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.state,
    required this.title,
    required this.description,
  });

  final ResultState state;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final isSuccess = state == ResultState.success;
    final colorScheme = Theme.of(context).colorScheme;
    final color = isSuccess ? Colors.green : colorScheme.error;
    final bgColor = color.withValues(alpha: 0.12);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: color,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

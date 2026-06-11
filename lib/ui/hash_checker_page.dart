import 'dart:async';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/hash_algorithms.dart';
import '../core/hash_reference.dart';
import '../core/hash_service.dart';
import '../core/path_utils.dart';
import '../l10n/app_localizations.dart';

class HashCheckerPage extends StatefulWidget {
  const HashCheckerPage({super.key});

  @override
  State<HashCheckerPage> createState() => _HashCheckerPageState();
}

class _HashCheckerPageState extends State<HashCheckerPage> {
  final HashService hashService = const HashService();
  final List<String> availableAlgos = supportedHashAlgorithms;
  final TextEditingController referenceHashController = TextEditingController();

  String selectedAlgo = 'SHA-256';

  String? filePath;
  String? hashPath;
  String? manualHash;
  String? calculatedHash;
  String? calculatedForFilePath;
  String? calculatedForAlgorithm;

  StreamSubscription<HashProgressEvent>? hashSubscription;
  int hashTaskId = 0;
  double hashProgress = 0;
  Duration estimatedRemaining = Duration.zero;

  bool isHashing = false;
  bool fileDone = false;
  bool isDialogOpen = false;
  bool isFileDropActive = false;
  bool isHashDropActive = false;

  ResultState resultState = ResultState.hidden;
  String resultTitle = '';
  String resultDescription = '';

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  bool get canVerify {
    return filePath != null && calculatedHash != null && (manualHash?.isNotEmpty ?? false);
  }

  @override
  void dispose() {
    unawaited(hashSubscription?.cancel());
    referenceHashController.dispose();
    super.dispose();
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
      final result = await pickSingleFile(l10n.selectFileForCheckDialog);
      if (result != null) {
        await setFileForCheck(result.path);
      }
    } finally {
      isDialogOpen = false;
    }
  }

  Future<void> pickHashFile() async {
    if (isDialogOpen) return;
    isDialogOpen = true;
    try {
      final result = await pickSingleFile(l10n.selectHashFileDialog);
      if (result != null) {
        await setHashFile(result.path);
      }
    } finally {
      isDialogOpen = false;
    }
  }

  Future<void> setFileForCheck(String path) async {
    filePath = path;
    await startHashing(path, force: true);
  }

  Future<void> setHashFile(String path) async {
    hashPath = path;
    try {
      final content = await hashService.readTextFile(path);
      final ok = processHashInput(content.trim(), basename(path));
      if (!ok) {
        setState(() {
          manualHash = null;
          resultState = ResultState.hidden;
        });
        referenceHashController.clear();
      }
    } catch (_) {
      showToast(l10n.readFileError);
    }
  }

  Future<void> handleDroppedFileForCheck(List<XFile> files) async {
    if (files.isEmpty) return;
    setState(() {
      isFileDropActive = false;
    });
    await setFileForCheck(files.first.path);
  }

  Future<void> handleDroppedHashFile(List<XFile> files) async {
    if (files.isEmpty) return;
    setState(() {
      isHashDropActive = false;
    });
    await setHashFile(files.first.path);
  }

  Future<XFile?> pickSingleFile(String confirmButtonText) async {
    try {
      return await openFile(confirmButtonText: confirmButtonText);
    } catch (_) {
      showToast(l10n.openFileDialogError);
      return null;
    }
  }

  Future<void> pasteHash() async {
    final text = await Clipboard.getData(Clipboard.kTextPlain);
    final ok = processHashInput(text?.text, l10n.fromClipboard);
    if (!ok) {
      showToast(l10n.invalidHashFormat);
    }
  }

  bool processHashInput(String? rawText, String sourceDisplayName) {
    final reference = parseHashReference(rawText, sourceDisplayName);
    if (reference == null) return false;

    applyHashReference(reference, updateInput: true);
    return true;
  }

  void updateReferenceHashInput(String rawText) {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) {
      setState(() {
        hashPath = null;
        manualHash = null;
        resultState = ResultState.hidden;
        _hashSubtitleOverride = null;
      });
      return;
    }

    final reference = parseHashReference(trimmed, l10n.manualHashSource);
    if (reference == null) {
      setState(() {
        hashPath = null;
        manualHash = null;
        resultState = ResultState.hidden;
        _hashSubtitleOverride = null;
      });
      return;
    }

    hashPath = null;
    applyHashReference(reference, updateInput: false);
  }

  void applyHashReference(HashReference reference, {required bool updateInput}) {
    String? toastMessage;
    var shouldRehash = false;
    if (reference.detectedAlgorithm != null && selectedAlgo != reference.detectedAlgorithm) {
      selectedAlgo = reference.detectedAlgorithm!;
      toastMessage = l10n.algorithmChanged(reference.detectedAlgorithm!);
      shouldRehash = filePath != null;
    }

    setState(() {
      manualHash = reference.hash;
      resultState = ResultState.hidden;
      _hashSubtitleOverride = reference.subtitle;
    });

    if (updateInput) {
      referenceHashController.value = TextEditingValue(
        text: reference.hash,
        selection: TextSelection.collapsed(offset: reference.hash.length),
      );
    }

    if (toastMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showToast(toastMessage!));
    }

    if (shouldRehash && filePath != null) {
      unawaited(startHashing(filePath!));
    }
  }

  Future<void> startHashing(String path, {bool force = false}) async {
    final algo = selectedAlgo;
    if (!force && calculatedForFilePath == path && calculatedForAlgorithm == algo) {
      return;
    }

    await hashSubscription?.cancel();
    final taskId = ++hashTaskId;

    setState(() {
      calculatedHash = null;
      calculatedForFilePath = null;
      calculatedForAlgorithm = null;
      hashProgress = 0;
      estimatedRemaining = Duration.zero;
      isHashing = true;
      fileDone = false;
      resultState = ResultState.hidden;
    });

    hashSubscription = hashService.computeFileHashWithProgress(path, algo).listen(
      (event) {
        if (!mounted || taskId != hashTaskId || path != filePath || algo != selectedAlgo) {
          return;
        }
        switch (event) {
          case HashProgress():
            setState(() {
              hashProgress = event.fraction;
              estimatedRemaining = event.estimatedRemaining;
            });
          case HashCompleted():
            setState(() {
              calculatedHash = event.hash;
              calculatedForFilePath = path;
              calculatedForAlgorithm = algo;
              hashProgress = 1;
              estimatedRemaining = Duration.zero;
              isHashing = false;
              fileDone = true;
            });
        }
      },
      onError: (_, _) {
        if (!mounted || taskId != hashTaskId || path != filePath) return;
        setState(() {
          isHashing = false;
          fileDone = false;
          hashProgress = 0;
          estimatedRemaining = Duration.zero;
        });
        showToast(l10n.readFileError);
      },
    );
  }

  Future<void> copyCalculatedHash() async {
    final hash = calculatedHash;
    if (hash == null) return;
    await Clipboard.setData(ClipboardData(text: hash));
    showToast(l10n.hashCopied);
  }

  Future<void> changeAlgorithm(String value) async {
    if (value == selectedAlgo) return;
    setState(() {
      selectedAlgo = value;
    });
    if (filePath != null) {
      await startHashing(filePath!);
    }
  }

  void showHelp() {
    showDialog<void>(
      context: context,
      builder: (context) => _HelpDialog(
        title: l10n.helpTitle,
        overview: l10n.helpOverview,
        stepsTitle: l10n.helpStepsTitle,
        steps: [
          l10n.helpStepChooseFile,
          l10n.helpStepReferenceHash,
          l10n.helpStepAlgorithm,
          l10n.helpStepCompare,
        ],
        featuresTitle: l10n.helpFeaturesTitle,
        features: [
          l10n.helpFeatureDragDrop,
          l10n.helpFeatureProgress,
          l10n.helpFeatureCopyHash,
        ],
        closeLabel: l10n.closeButton,
      ),
    );
  }

  String formatRemainingTime(Duration duration) {
    if (duration.inMilliseconds <= 0) return l10n.lessThanSecond;
    if (duration.inSeconds < 1) return l10n.lessThanSecond;
    if (duration.inMinutes < 1) return l10n.secondsShort(duration.inSeconds);
    return l10n.minutesSecondsShort(duration.inMinutes, duration.inSeconds % 60);
  }

  String get progressText {
    final percent = (hashProgress * 100).clamp(0, 100).round();
    return l10n.hashProgress(percent, formatRemainingTime(estimatedRemaining));
  }

  Future<void> verifyHashes() async {
    String? expected = manualHash;

    if ((expected == null || expected.isEmpty) && hashPath != null) {
      try {
        final content = await hashService.readTextFile(hashPath!);
        expected = parseHashReference(content, basename(hashPath!))?.hash;
      } catch (_) {
        showToast(l10n.readFileError);
        return;
      }
    }

    if (expected == null || expected.isEmpty || calculatedHash == null) {
      return;
    }

    setState(() {
      if (hashService.hashesMatch(calculatedHash!, expected!)) {
        resultState = ResultState.success;
        resultTitle = l10n.hashesMatchTitle;
        resultDescription = l10n.hashesMatchDescription(selectedAlgo);
      } else {
        resultState = ResultState.error;
        resultTitle = l10n.hashesDifferTitle;
        resultDescription = l10n.hashesDifferDescription;
      }
    });
  }

  String? _hashSubtitleOverride;

  String get fileSubtitle {
    if (filePath == null) return l10n.chooseFilePlaceholder;
    if (isHashing) return l10n.hashingStatus(selectedAlgo);
    return basename(filePath!);
  }

  String get hashSubtitle {
    if (_hashSubtitleOverride != null) return _hashSubtitleOverride!;
    return l10n.hashReferencePlaceholder;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionCard(
                    title: l10n.settingsSection,
                    trailing: IconButton(
                      tooltip: l10n.helpTooltip,
                      onPressed: showHelp,
                      icon: const Icon(Icons.help_outline),
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedAlgo,
                      decoration: InputDecoration(
                        labelText: l10n.hashAlgorithmLabel,
                        border: OutlineInputBorder(),
                      ),
                      items: availableAlgos
                          .map((algo) => DropdownMenuItem(value: algo, child: Text(algo)))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        unawaited(changeAlgorithm(value));
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: l10n.verificationDataSection,
                    child: Column(
                      children: [
                        DropTarget(
                          onDragDone: (detail) => unawaited(handleDroppedFileForCheck(detail.files)),
                          onDragEntered: (_) => setState(() => isFileDropActive = true),
                          onDragExited: (_) => setState(() => isFileDropActive = false),
                          child: _ActionTile(
                            icon: Icons.insert_drive_file_outlined,
                            title: l10n.fileForCheckTitle,
                            subtitle: isFileDropActive ? l10n.dropFileForCheck : fileSubtitle,
                            highlighted: isFileDropActive,
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
                                  tooltip: l10n.chooseFileTooltip,
                                  onPressed: pickFileForCheck,
                                  icon: const Icon(Icons.folder_open),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropTarget(
                          onDragDone: (detail) => unawaited(handleDroppedHashFile(detail.files)),
                          onDragEntered: (_) => setState(() => isHashDropActive = true),
                          onDragExited: (_) => setState(() => isHashDropActive = false),
                          child: _ReferenceHashEditor(
                            title: l10n.referenceHashTitle,
                            controller: referenceHashController,
                            hintText: isHashDropActive ? l10n.dropHashFile : l10n.hashReferencePlaceholder,
                            sourceText: _hashSubtitleOverride,
                            highlighted: isHashDropActive,
                            pasteTooltip: l10n.pasteFromClipboardTooltip,
                            chooseFileTooltip: l10n.chooseHashFileTooltip,
                            onChanged: updateReferenceHashInput,
                            onPaste: pasteHash,
                            onChooseFile: pickHashFile,
                          ),
                        ),
                        if (isHashing) ...[
                          const SizedBox(height: 16),
                          _HashProgressView(
                            progress: hashProgress,
                            label: progressText,
                          ),
                        ],
                        if (calculatedHash != null) ...[
                          const SizedBox(height: 16),
                          _CalculatedHashCard(
                            title: l10n.calculatedHashTitle,
                            hash: calculatedHash!,
                            copyTooltip: l10n.copyHashTooltip,
                            onCopy: copyCalculatedHash,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilledButton(
                          onPressed: canVerify ? verifyHashes : null,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(220, 48),
                          ),
                          child: Text(l10n.verifyButton),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: resultState == ResultState.hidden
                              ? const SizedBox(width: 48, key: ValueKey('empty-result'))
                              : Padding(
                                  key: ValueKey(resultState),
                                  padding: const EdgeInsets.only(left: 12),
                                  child: _ResultIndicator(
                                    state: resultState,
                                    title: resultTitle,
                                    description: resultDescription,
                                  ),
                                ),
                        ),
                      ],
                    ),
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

class _HelpDialog extends StatelessWidget {
  const _HelpDialog({
    required this.title,
    required this.overview,
    required this.stepsTitle,
    required this.steps,
    required this.featuresTitle,
    required this.features,
    required this.closeLabel,
  });

  final String title;
  final String overview;
  final String stepsTitle;
  final List<String> steps;
  final String featuresTitle;
  final List<String> features;
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(overview),
              const SizedBox(height: 18),
              _HelpSection(title: stepsTitle, items: steps),
              const SizedBox(height: 16),
              _HelpSection(title: featuresTitle, items: features),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(closeLabel),
        ),
      ],
    );
  }
}

class _HelpSection extends StatelessWidget {
  const _HelpSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Icon(
                    Icons.circle,
                    size: 6,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(item)),
              ],
            ),
          ),
      ],
    );
  }
}

enum ResultState { hidden, success, error }

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: Theme.of(context).textTheme.titleMedium),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 12),
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
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: highlighted ? scheme.primaryContainer.withValues(alpha: 0.45) : null,
        border: Border.all(
          color: highlighted ? scheme.primary : scheme.outlineVariant,
          width: highlighted ? 2 : 1,
        ),
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

class _ReferenceHashEditor extends StatelessWidget {
  const _ReferenceHashEditor({
    required this.title,
    required this.controller,
    required this.hintText,
    required this.highlighted,
    required this.pasteTooltip,
    required this.chooseFileTooltip,
    required this.onChanged,
    required this.onPaste,
    required this.onChooseFile,
    this.sourceText,
  });

  final String title;
  final TextEditingController controller;
  final String hintText;
  final String? sourceText;
  final bool highlighted;
  final String pasteTooltip;
  final String chooseFileTooltip;
  final ValueChanged<String> onChanged;
  final VoidCallback onPaste;
  final VoidCallback onChooseFile;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final source = sourceText;

    return Container(
      decoration: BoxDecoration(
        color: highlighted ? scheme.primaryContainer.withValues(alpha: 0.45) : null,
        border: Border.all(
          color: highlighted ? scheme.primary : scheme.outlineVariant,
          width: highlighted ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            onChanged: onChanged,
            minLines: 1,
            maxLines: 3,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: pasteTooltip,
                    onPressed: onPaste,
                    icon: const Icon(Icons.content_paste),
                  ),
                  IconButton(
                    tooltip: chooseFileTooltip,
                    onPressed: onChooseFile,
                    icon: const Icon(Icons.folder_open),
                  ),
                ],
              ),
            ),
          ),
          if (source != null) ...[
            const SizedBox(height: 8),
            Text(
              source,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _HashProgressView extends StatelessWidget {
  const _HashProgressView({
    required this.progress,
    required this.label,
  });

  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: progress <= 0 ? null : progress),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CalculatedHashCard extends StatelessWidget {
  const _CalculatedHashCard({
    required this.title,
    required this.hash,
    required this.copyTooltip,
    required this.onCopy,
  });

  final String title;
  final String hash;
  final String copyTooltip;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: Theme.of(context).textTheme.titleSmall),
              ),
              IconButton(
                tooltip: copyTooltip,
                onPressed: onCopy,
                icon: const Icon(Icons.copy),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            hash,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _ResultIndicator extends StatelessWidget {
  const _ResultIndicator({
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

    return Tooltip(
      message: '$title\n$description',
      child: Semantics(
        label: '$title. $description',
        child: Icon(
          isSuccess ? Icons.check_circle : Icons.cancel,
          color: color,
          size: 36,
        ),
      ),
    );
  }
}

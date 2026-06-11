import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

class HashService {
  const HashService();

  Future<String> computeFileHash(String path, String algorithmName) async {
    await for (final event in computeFileHashWithProgress(path, algorithmName)) {
      if (event is HashCompleted) {
        return event.hash;
      }
    }
    throw StateError('Hash computation did not complete.');
  }

  Stream<HashProgressEvent> computeFileHashWithProgress(String path, String algorithmName) {
    late StreamController<HashProgressEvent> controller;
    Isolate? isolate;
    ReceivePort? receivePort;

    controller = StreamController<HashProgressEvent>(
      onListen: () async {
        receivePort = ReceivePort();
        receivePort!.listen(
          (message) {
            if (message is Map) {
              final type = message['type'];
              if (type == 'progress') {
                controller.add(
                  HashProgress(
                    processedBytes: message['processedBytes'] as int,
                    totalBytes: message['totalBytes'] as int,
                    elapsed: Duration(milliseconds: message['elapsedMs'] as int),
                    estimatedRemaining:
                        Duration(milliseconds: message['estimatedRemainingMs'] as int),
                  ),
                );
              } else if (type == 'completed') {
                controller.add(HashCompleted(message['hash'] as String));
                controller.close();
              } else if (type == 'error') {
                controller.addError(
                  HashComputationException(message['message'] as String),
                  StackTrace.fromString(message['stackTrace'] as String),
                );
                controller.close();
              }
            }
          },
          onDone: () {
            if (!controller.isClosed) {
              controller.close();
            }
          },
        );

        try {
          isolate = await Isolate.spawn(
            _hashWorker,
            _HashWorkerRequest(
              path: path,
              algorithmName: algorithmName,
              sendPort: receivePort!.sendPort,
            ),
          );
        } catch (error, stackTrace) {
          controller.addError(error, stackTrace);
          controller.close();
        }
      },
      onCancel: () {
        isolate?.kill(priority: Isolate.immediate);
        receivePort?.close();
      },
    );

    return controller.stream;
  }

  static void _hashWorker(_HashWorkerRequest request) {
    try {
      final hash = _computeFileHashSync(
        request.path,
        request.algorithmName,
        request.sendPort,
      );
      request.sendPort.send({
        'type': 'completed',
        'hash': hash,
      });
    } catch (error, stackTrace) {
      request.sendPort.send({
        'type': 'error',
        'message': error.toString(),
        'stackTrace': stackTrace.toString(),
      });
    }
  }

  static String _computeFileHashSync(
    String path,
    String algorithmName,
    SendPort sendPort,
  ) {
    final digestSink = AccumulatorSink<Digest>();
    late ByteConversionSink input;

    switch (algorithmName) {
      case 'SHA-256':
        input = sha256.startChunkedConversion(digestSink);
        break;
      case 'SHA-512':
        input = sha512.startChunkedConversion(digestSink);
        break;
      case 'SHA-1':
        input = sha1.startChunkedConversion(digestSink);
        break;
      case 'MD5':
        input = md5.startChunkedConversion(digestSink);
        break;
      default:
        throw UnsupportedError('Unknown algorithm: $algorithmName');
    }

    final file = File(path);
    final totalBytes = file.lengthSync();
    final reader = file.openSync();
    final stopwatch = Stopwatch()..start();
    var processedBytes = 0;
    var lastReportMs = -250;

    try {
      while (true) {
        final chunk = reader.readSync(1024 * 1024);
        if (chunk.isEmpty) break;

        input.add(chunk);
        processedBytes += chunk.length;

        final elapsedMs = stopwatch.elapsedMilliseconds;
        final shouldReport = elapsedMs - lastReportMs >= 250 || processedBytes == totalBytes;
        if (shouldReport) {
          lastReportMs = elapsedMs;
          sendPort.send({
            'type': 'progress',
            'processedBytes': processedBytes,
            'totalBytes': totalBytes,
            'elapsedMs': elapsedMs,
            'estimatedRemainingMs': _estimateRemainingMs(
              processedBytes: processedBytes,
              totalBytes: totalBytes,
              elapsedMs: elapsedMs,
            ),
          });
        }
      }
    } finally {
      reader.closeSync();
    }

    input.close();

    return digestSink.events.single.toString();
  }

  Future<String> readTextFile(String path) {
    return File(path).readAsString();
  }

  bool hashesMatch(String calculated, String expected) {
    return calculated.toLowerCase() == expected.toLowerCase();
  }

  static int _estimateRemainingMs({
    required int processedBytes,
    required int totalBytes,
    required int elapsedMs,
  }) {
    if (processedBytes <= 0 || totalBytes <= 0 || elapsedMs <= 0) return 0;
    final remainingBytes = math.max(0, totalBytes - processedBytes);
    final bytesPerMs = processedBytes / elapsedMs;
    if (bytesPerMs <= 0) return 0;
    return (remainingBytes / bytesPerMs).round();
  }
}

sealed class HashProgressEvent {
  const HashProgressEvent();
}

class HashProgress extends HashProgressEvent {
  const HashProgress({
    required this.processedBytes,
    required this.totalBytes,
    required this.elapsed,
    required this.estimatedRemaining,
  });

  final int processedBytes;
  final int totalBytes;
  final Duration elapsed;
  final Duration estimatedRemaining;

  double get fraction {
    if (totalBytes <= 0) return 0;
    return (processedBytes / totalBytes).clamp(0, 1).toDouble();
  }
}

class HashCompleted extends HashProgressEvent {
  const HashCompleted(this.hash);

  final String hash;
}

class HashComputationException implements Exception {
  const HashComputationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _HashWorkerRequest {
  const _HashWorkerRequest({
    required this.path,
    required this.algorithmName,
    required this.sendPort,
  });

  final String path;
  final String algorithmName;
  final SendPort sendPort;
}

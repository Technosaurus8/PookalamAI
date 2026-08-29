import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../services/worker_service.dart';

class WorkerTestScreen extends StatefulWidget {
  const WorkerTestScreen({super.key});

  @override
  State<WorkerTestScreen> createState() => _WorkerTestScreenState();
}

class _WorkerTestScreenState extends State<WorkerTestScreen> {
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _result;

  Future<void> _runTest() async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final bytes = await rootBundle.load('assets/drawn_pookalam.png');
      final base64Image = base64Encode(bytes.buffer.asUint8List());
      final result = await WorkerService.scoreImage(base64Image);
      setState(() => _result = result);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Worker Test')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Image.asset('assets/drawn_pookalam.png', height: 200),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _runTest,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send to AI'),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_result != null) ...[
              Text(
                'Score: ${_result!['score']}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '"${_result!['comment']}"',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              Text(
                _result.toString(),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

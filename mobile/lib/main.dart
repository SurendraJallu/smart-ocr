import 'package:flutter/material.dart';

void main() {
  runApp(const SmartOcrApp());
}

class SmartOcrApp extends StatelessWidget {
  const SmartOcrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart OCR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2457C5)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart OCR')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.document_scanner_outlined, size: 72),
              const SizedBox(height: 16),
              Text(
                'Your documents, searchable.',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Capture or import a document to extract text.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Capture document'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Choose from gallery'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Capture and OCR features are added in the next development step.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

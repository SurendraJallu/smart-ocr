import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// Flutter's Material library remains the supported import for this app's widget set.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

const apiBaseUrl = String.fromEnvironment(
  'SMART_OCR_API_URL',
  defaultValue: 'http://10.0.2.2:8081/api/v1',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (_) {
    // Firebase-dependent server OCR and document saving remain unavailable until configured.
  }
  runApp(SmartOcrApp(firebaseReady: firebaseReady));
}

class SmartOcrApp extends StatelessWidget {
  const SmartOcrApp({required this.firebaseReady, super.key});
  final bool firebaseReady;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Smart OCR',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2457C5)),
          useMaterial3: true,
        ),
        home: HomePage(firebaseReady: firebaseReady),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({required this.firebaseReady, super.key});
  final bool firebaseReady;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _picker = ImagePicker();
  final _textController = TextEditingController();
  final _titleController = TextEditingController(text: 'New document');
  File? _image;
  bool _processing = false;
  bool _saving = false;
  String? _message;
  String _documentType = 'GENERAL';

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 95);
    if (picked == null || !mounted) return;
    setState(() {
      _image = File(picked.path);
      _processing = true;
      _message = null;
      _textController.clear();
    });
    await _recognizeOnServer(picked.path);
  }

  Future<void> _recognizeOnServer(String imagePath) async {
    final user = widget.firebaseReady ? FirebaseAuth.instance.currentUser : null;
    if (user == null) {
      if (mounted) {
        setState(() {
          _processing = false;
          _message = 'Sign in to upload this image for server-side OCR.';
        });
      }
      return;
    }

    try {
      final token = await user.getIdToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiBaseUrl/ocr/recognize'),
      )
        ..headers[HttpHeaders.authorizationHeader] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('image', imagePath));
      final streamed = await request.send().timeout(const Duration(seconds: 70));
      final response = await http.Response.fromStream(streamed);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final payload = jsonDecode(response.body) as Map<String, dynamic>;
        final recognizedText = payload['text'] as String? ?? '';
        setState(() {
          _textController.text = recognizedText;
          _processing = false;
          _message = recognizedText.trim().isEmpty
              ? 'No text found. Try a clearer image with better lighting.'
              : 'Server OCR complete. Review and correct the text before saving.';
        });
      } else {
        setState(() {
          _processing = false;
          _message = 'Server OCR failed (HTTP ${response.statusCode}). Check the server OCR setup.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _processing = false;
          _message = 'Could not reach the OCR server. Check your connection and API URL.';
        });
      }
    }
  }

  Future<void> _saveDocument() async {
    final user = widget.firebaseReady ? FirebaseAuth.instance.currentUser : null;
    if (user == null) {
      setState(() => _message =
          'Configure Firebase and sign in to use server OCR and save documents to your account.');
      return;
    }
    if (_textController.text.trim().isEmpty) {
      setState(() => _message = 'There is no recognized text to save.');
      return;
    }
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      final token = await user.getIdToken();
      final response = await http.post(
        Uri.parse('$apiBaseUrl/documents'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode({
          'title': _titleController.text.trim().isEmpty
              ? 'Untitled document'
              : _titleController.text.trim(),
          'documentType': _documentType,
          'extractedText': _textController.text,
          'status': 'REVIEW_REQUIRED',
        }),
      );
      if (!mounted) return;
      setState(() => _message = response.statusCode == 201
          ? 'Document saved to your account.'
          : 'Could not save document (HTTP ${response.statusCode}). Check API configuration.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = 'Could not reach the API. Check the server URL and connection.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _signIn() async {
    final email = TextEditingController();
    final password = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign in'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: email, keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: password, obscureText: true,
                decoration: const InputDecoration(labelText: 'Password')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Continue')),
        ],
      ),
    );
    if (accepted == true) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text,
        );
        if (mounted) setState(() => _message = 'Signed in successfully.');
      } on FirebaseAuthException catch (error) {
        if (mounted) setState(() => _message = error.message ?? 'Sign-in failed.');
      }
    }
    email.dispose();
    password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.firebaseReady ? FirebaseAuth.instance.currentUser : null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart OCR'),
        actions: [
          if (user != null)
            IconButton(
              tooltip: 'Sign out',
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) setState(() => _message = 'Signed out.');
              },
              icon: const Icon(Icons.logout),
            )
          else
            TextButton(onPressed: widget.firebaseReady ? _signIn : null, child: const Text('Sign in')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.document_scanner_outlined, size: 64),
          const SizedBox(height: 12),
          Text('Scan. Recognize. Review.',
              style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('Images are uploaded to the Smart OCR server for English text recognition.',
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: FilledButton.icon(
                onPressed: _processing ? null : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined), label: const Text('Camera'))),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton.icon(
                onPressed: _processing ? null : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined), label: const Text('Gallery'))),
            ],
          ),
          if (_image != null) ...[
            const SizedBox(height: 20),
            ClipRRect(borderRadius: BorderRadius.circular(12),
                child: Image.file(_image!, height: 220, fit: BoxFit.contain)),
          ],
          if (_processing) ...[
            const SizedBox(height: 20),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            const Text('Uploading image and recognizing text on server…', textAlign: TextAlign.center),
          ],
          const SizedBox(height: 20),
          TextField(controller: _titleController,
              decoration: const InputDecoration(labelText: 'Document title', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _documentType,
            decoration: const InputDecoration(labelText: 'Document type', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'GENERAL', child: Text('General')),
              DropdownMenuItem(value: 'AADHAAR', child: Text('Aadhaar')),
              DropdownMenuItem(value: 'PAN', child: Text('PAN')),
              DropdownMenuItem(value: 'MARKSHEET', child: Text('Marksheet')),
              DropdownMenuItem(value: 'VEHICLE_RC', child: Text('Vehicle RC')),
              DropdownMenuItem(value: 'PRESCRIPTION', child: Text('Prescription')),
            ],
            onChanged: (value) => setState(() => _documentType = value ?? 'GENERAL'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController, minLines: 8, maxLines: 16,
            decoration: const InputDecoration(
              labelText: 'Recognized text — review and edit',
              alignLabelWithHint: true, border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _saving || _processing ? null : _saveDocument,
            icon: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.cloud_upload_outlined),
            label: Text(_saving ? 'Saving…' : 'Save to my documents'),
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(_message!, textAlign: TextAlign.center),
          ],
          const SizedBox(height: 12),
          const Text(
            'OCR can make mistakes. Verify all extracted values yourself, especially identity and medical information.',
            style: TextStyle(fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

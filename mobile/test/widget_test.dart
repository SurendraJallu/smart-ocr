import 'package:flutter_test/flutter_test.dart';
import 'package:smart_ocr/main.dart';

void main() {
  testWidgets('Smart OCR home screen renders', (tester) async {
    await tester.pumpWidget(const SmartOcrApp(firebaseReady: false));
    expect(find.text('Smart OCR'), findsOneWidget);
    expect(find.text('Scan. Recognize. Review.'), findsOneWidget);
  });
}
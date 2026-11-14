import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zana/main.dart';

void main() {
  testWidgets('ZanaApp builds', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ZanaApp()));
    // اسپلش تایمر دارد؛ فقط یک فریم
    await tester.pump();
    expect(find.byType(ZanaApp), findsOneWidget);
  });
}

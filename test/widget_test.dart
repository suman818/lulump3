import 'package:flutter_test/flutter_test.dart';
import 'package:premium_audio_player/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('foundation shell starts with ProviderScope', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PremiumAudioPlayerApp(),
      ),
    );

    expect(find.text('Premium Audio Player'), findsOneWidget);
    expect(
      find.text(
        'M1 foundation shell — product screens are not implemented yet.',
      ),
      findsOneWidget,
    );
  });
}

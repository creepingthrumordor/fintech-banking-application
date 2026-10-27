import 'package:fintrust/main.dart';
import 'package:fintrust/pages/receipt_page.dart';
import 'package:fintrust/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('main banking destinations are connected', (tester) async {
    await tester.pumpWidget(const FinTrustApp());

    expect(find.text('Afil Musthafa'), findsOneWidget);
    expect(find.text('LKR 231,570'), findsOneWidget);

    await tester.tap(find.text('Transfer').last);
    await tester.pumpAndSettle();
    expect(find.text('Money Transfer\n& Payment'), findsOneWidget);

    await tester.tap(find.text('Card'));
    await tester.pumpAndSettle();
    expect(find.text('My Cards'), findsOneWidget);

    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();
    expect(find.text('Transactions'), findsOneWidget);

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    expect(find.text('Authentication, privacy, and security controls'),
        findsOneWidget);
  });

  testWidgets('transfer confirmation updates dashboard balance and activity',
      (tester) async {
    await tester.pumpWidget(const FinTrustApp());

    await tester.tap(find.text('Transfer').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('kavinjan'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.hintText == '0.00',
      ),
      '5000',
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review transfer'));
    await tester.pumpAndSettle();

    expect(find.text('Send LKR 5,000 to kavinjan?'), findsOneWidget);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Transfer sent — you\'re all set!'), findsOneWidget);

    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(find.text('Transfer to kavinjan'), findsOneWidget);
  });

  testWidgets('dark mode switch toggles theme between light and dark',
      (tester) async {
    AppTheme.setTheme(ThemeMode.light);
    await tester.pumpWidget(const FinTrustApp());

    expect(AppTheme.isDark, isFalse);

    // Tap dark mode toggle in the top app bar
    final darkModeBtn = find.byTooltip('Switch to Dark Mode');
    expect(darkModeBtn, findsOneWidget);
    await tester.tap(darkModeBtn);
    await tester.pumpAndSettle();

    expect(AppTheme.isDark, isTrue);

    // Switch back to light mode
    final lightModeBtn = find.byTooltip('Switch to Light Mode');
    expect(lightModeBtn, findsOneWidget);
    await tester.tap(lightModeBtn);
    await tester.pumpAndSettle();

    expect(AppTheme.isDark, isFalse);
  });

  testWidgets('budgeting tips and financial recommendations are displayed',
      (tester) async {
    await tester.pumpWidget(const FinTrustApp());

    // Scroll down to view recommendations
    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();

    // Recommendations carousel
    expect(find.text('Smart AI Recommendations'), findsOneWidget);
    expect(find.text('Switch LKR 50,000 to High-Yield Vault'), findsOneWidget);

    // Scroll until budgeting tips banner is visible
    await tester.scrollUntilVisible(
      find.text('Budgeting Tips & Strategies'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // Budgeting tips banner
    expect(find.text('Budgeting Tips & Strategies'), findsOneWidget);

    // Tap budgeting tips banner to open modal sheet
    await tester.tap(find.text('Budgeting Tips & Strategies'));
    await tester.pumpAndSettle();

    expect(find.text('Budgeting & Saving Tips'), findsOneWidget);
    expect(find.text('The 50/30/20 Rule'), findsOneWidget);
  });

  testWidgets(
      'upcoming bill reminders are displayed and pay bill opens dedicated receipt',
      (tester) async {
    await tester.pumpWidget(const FinTrustApp());

    // Scroll down to upcoming bill reminders
    await tester.drag(find.byType(ListView).first, const Offset(0, -450));
    await tester.pumpAndSettle();

    expect(find.text('Upcoming Bill Reminders'), findsOneWidget);
    expect(find.text('Ceylon Electricity Board'), findsOneWidget);

    // Ensure Pay button is in view and tap it
    final payBtn = find.text('Pay').first;
    await tester.ensureVisible(payBtn);
    await tester.pumpAndSettle();
    await tester.tap(payBtn);
    await tester.pumpAndSettle();

    // Verifies dedicated confirmation/receipt screen opens
    expect(find.text('Payment Receipt'), findsOneWidget);
    expect(find.text('TRANSACTION SUCCESSFUL'), findsOneWidget);
    expect(find.text('Download PDF'), findsOneWidget);
    expect(find.text('Share Receipt'), findsOneWidget);
  });

  testWidgets('voice search icon opens interactive voice listening sheet',
      (tester) async {
    await tester.pumpWidget(const FinTrustApp());

    final voiceBtn = find.byTooltip('Voice Search').first;
    expect(voiceBtn, findsOneWidget);
    await tester.tap(voiceBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Fin Voice Search'), findsOneWidget);
    expect(
        find.text('Listening... Speak your financial command'), findsOneWidget);
    expect(find.text('Send LKR 5,000 to kavinjan'), findsOneWidget);
  });

  testWidgets('dedicated confirmation/receipt screen displays full details',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ConfirmationReceiptPage(
          recipientName: 'kavinjan',
          recipientAccount: '0123 9912 307',
          amount: 5000,
          referenceId: 'FT-2026-TEST1234',
          category: 'Money Transfer',
          note: 'Dinner split payment',
        ),
      ),
    );

    expect(find.text('Payment Receipt'), findsOneWidget);
    expect(find.text('TRANSACTION SUCCESSFUL'), findsOneWidget);
    expect(find.text('LKR 5,000'), findsOneWidget);
    expect(find.text('kavinjan'), findsOneWidget);
    expect(find.text('FT-2026-TEST1234'), findsNWidgets(2));
    expect(find.text('Dinner split payment'), findsOneWidget);
    expect(find.text('Download PDF'), findsOneWidget);
    expect(find.text('Share Receipt'), findsOneWidget);
  });
}

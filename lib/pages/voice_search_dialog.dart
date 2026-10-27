import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shows an interactive animated Material 3 Voice Search Sheet
void showVoiceSearchSheet({
  required BuildContext context,
  required Function(String query) onQuerySelected,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor:
        Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => _VoiceSearchSheet(onQuerySelected: onQuerySelected),
  );
}

class _VoiceSearchSheet extends StatefulWidget {
  final Function(String query) onQuerySelected;

  const _VoiceSearchSheet({required this.onQuerySelected});

  @override
  State<_VoiceSearchSheet> createState() => _VoiceSearchSheetState();
}

class _VoiceSearchSheetState extends State<_VoiceSearchSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _statusText = 'Listening... Speak your financial command';
  String? _recognizedText;
  Timer? _simulatedTimer;

  static const _suggestions = [
    'Send LKR 5,000 to kavinjan',
    'Show upcoming bills',
    'Budgeting tips for savings',
    'What is my total balance?',
    'Freeze debit card',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Simulate listening feedback
    _simulatedTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _recognizedText == null) {
        setState(() {
          _statusText = 'Try speaking one of the commands below:';
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _simulatedTimer?.cancel();
    super.dispose();
  }

  void _selectCommand(String command) {
    setState(() {
      _recognizedText = command;
      _statusText = 'Executing command...';
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        Navigator.pop(context);
        widget.onQuerySelected(command);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(context).viewInsets.bottom + 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mic_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Fin Voice Search',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Pulsing microphone visualizer
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                final scale = 1.0 + (_animController.value * 0.18);
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 90 * scale,
                      height: 90 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withValues(
                            alpha: 0.15 - (_animController.value * 0.08)),
                      ),
                    ),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 18),

            // Audio wave visualizer bars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    final height = 12.0 +
                        (20.0 *
                            ((_animController.value + (index * 0.2)) % 1.0));
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 4,
                      height: height,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 16),

            // Status / recognized text
            Text(
              _recognizedText ?? _statusText,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight:
                    _recognizedText != null ? FontWeight.w700 : FontWeight.w500,
                color: _recognizedText != null
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            // Suggested voice commands
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Try saying or tap to execute:',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestions.map((cmd) {
                return ActionChip(
                  avatar: const Icon(Icons.arrow_forward_rounded, size: 14),
                  label: Text(cmd),
                  onPressed: () => _selectCommand(cmd),
                  backgroundColor: isDark
                      ? const Color(0xFF2B2836)
                      : const Color(0xFFF3EDF7),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

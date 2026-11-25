import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../game/round_engine.dart';
import '../../l10n/strings.dart';

/// Shows the parent gate. True when an adult got through.
Future<bool> requireParent(BuildContext context) async =>
    (await context.push<bool>('/gate')) ?? false;

/// "Grown-ups only": tap three digits that are written out as words.
/// Guards the parent zone, purchases and the "this is X" override.
class GateScreen extends ConsumerStatefulWidget {
  const GateScreen({super.key, this.random});

  final Random? random;

  @override
  ConsumerState<GateScreen> createState() => _GateScreenState();
}

class _GateScreenState extends ConsumerState<GateScreen> {
  late final Random _random = widget.random ?? Random();
  late GateChallenge _challenge = GateChallenge.random(_random);
  final _entered = <int>[];
  bool _wrong = false;

  void _tap(int digit) {
    if (_entered.length >= 3) return;
    HapticFeedback.selectionClick();
    setState(() {
      _wrong = false;
      _entered.add(digit);
    });
    if (_entered.length == 3) {
      if (_challenge.accepts(_entered)) {
        context.pop(true);
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _wrong = true;
          _entered.clear();
          _challenge = GateChallenge.random(_random);
        });
      }
    }
  }

  void _back() {
    if (_entered.isEmpty) return;
    setState(() => _entered.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final words = [for (final d in _challenge.digits) s.digits[d]].join(', ');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: s.t('close'),
                  icon: const Icon(Icons.close_rounded, size: 30),
                  onPressed: () => context.pop(false),
                ),
              ),
              const Icon(Icons.lock_rounded, color: FoxColors.jungle, size: 44),
              const SizedBox(height: 8),
              Text(s.t('parentOnly'), style: display(30)),
              const SizedBox(height: 12),
              Text(
                s.t('tapDigits', {'digits': words}),
                key: const Key('gate-instruction'),
                style: body(20, color: FoxColors.muted, weight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 3; i++)
                    Container(
                      width: 56,
                      height: 64,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: FoxColors.ground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _wrong
                              ? FoxColors.coral
                              : i == _entered.length
                                  ? FoxColors.jungle
                                  : FoxColors.line,
                          width: 3,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        i < _entered.length ? '${_entered[i]}' : '',
                        style: display(30),
                      ),
                    ),
                ],
              ),
              SizedBox(
                height: 32,
                child: _wrong
                    ? Center(
                        child: Text(s.t('wrongCode'),
                            style: body(16, color: FoxColors.coral)),
                      )
                    : null,
              ),
              const Spacer(),
              _Keypad(onDigit: _tap, onBack: _back),
            ],
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigit, required this.onBack});

  final ValueChanged<int> onDigit;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    Widget key(Widget child, VoidCallback? onTap, {String? label}) => Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Semantics(
              button: onTap != null,
              label: label,
              child: Material(
                color: onTap == null ? Colors.transparent : FoxColors.ground,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: onTap,
                  child: SizedBox(height: 64, child: Center(child: child)),
                ),
              ),
            ),
          ),
        );

    Widget digit(int d) =>
        key(Text('$d', style: display(30)), () => onDigit(d));

    return Column(
      children: [
        for (final row in const [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(children: [for (final d in row) digit(d)]),
        Row(
          children: [
            key(const SizedBox(), null),
            digit(0),
            key(const Icon(Icons.backspace_outlined), onBack, label: '⌫'),
          ],
        ),
      ],
    );
  }
}

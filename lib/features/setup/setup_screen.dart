import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../data/app_store.dart';
import '../../l10n/languages.dart';
import '../../l10n/strings.dart';
import '../../widgets/common.dart';
import '../../widgets/fox.dart';

/// First launch, for the parent: child's name and age, and the language
/// pair. Nothing here leaves the phone.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key, required this.deviceLanguage});

  final String deviceLanguage;

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _name = TextEditingController();
  int? _age;
  late String _native = defaultNativeLanguage(widget.deviceLanguage);
  late String _learn = defaultLearnLanguage(_native);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Strings(_native);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            const Center(child: Fox(size: 120)),
            const SizedBox(height: 12),
            Text(s.t('welcome'),
                style: display(34), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(s.t('setupIntro'),
                style: body(17,
                    color: FoxColors.muted, weight: FontWeight.w600),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            LanguagePairPicker(
              strings: s,
              native: _native,
              learn: _learn,
              onChanged: (native, learn) => setState(() {
                _native = native;
                _learn = learn;
              }),
            ),
            const SizedBox(height: 20),
            ProfileFields(
              strings: s,
              name: _name,
              age: _age,
              onAge: (a) => setState(() => _age = a),
            ),
            const SizedBox(height: 32),
            BigButton(
              label: s.t('done'),
              icon: Icons.check_rounded,
              onPressed: () {
                final name = _name.text.trim();
                ref.read(appStoreProvider.notifier).completeSetup(
                      name: name.isEmpty ? s.t('player') : name,
                      age: _age,
                      nativeLang: _native,
                      learnLang: _learn,
                    );
                context.go('/');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Two language dropdowns. The learned language can't equal the child's.
class LanguagePairPicker extends StatelessWidget {
  const LanguagePairPicker({
    super.key,
    required this.strings,
    required this.native,
    required this.learn,
    required this.onChanged,
  });

  final Strings strings;
  final String native;
  final String learn;
  final void Function(String native, String learn) onChanged;

  @override
  Widget build(BuildContext context) {
    Widget picker(String label, String value, List<Language> options,
            ValueChanged<String> onPick) =>
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: body(14,
                      color: FoxColors.muted, weight: FontWeight.w800)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                initialValue: value,
                isExpanded: true,
                decoration: _fieldDecoration(),
                items: [
                  for (final l in options)
                    DropdownMenuItem(
                        value: l.code, child: Text(l.name, style: body(17))),
                ],
                onChanged: (v) => v == null ? null : onPick(v),
              ),
            ],
          ),
        );

    return Row(
      children: [
        picker(strings.t('childLanguage'), native, languages, (n) {
          onChanged(n, n == learn ? defaultLearnLanguage(n) : learn);
        }),
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 20, 8, 0),
          child: Icon(Icons.arrow_forward_rounded, color: FoxColors.muted),
        ),
        picker(
          strings.t('learnLanguage'),
          learn,
          [for (final l in languages) if (l.code != native) l],
          (l) => onChanged(native, l),
        ),
      ],
    );
  }
}

InputDecoration _fieldDecoration({String? label}) => InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: FoxColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: FoxColors.line, width: 2),
      ),
    );

/// Child's name and an age picker (4–8).
class ProfileFields extends StatelessWidget {
  const ProfileFields({
    super.key,
    required this.strings,
    required this.name,
    required this.age,
    required this.onAge,
  });

  final Strings strings;
  final TextEditingController name;
  final int? age;
  final ValueChanged<int?> onAge;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: name,
            textCapitalization: TextCapitalization.words,
            maxLength: 20,
            style: body(18),
            decoration: _fieldDecoration(label: strings.t('childName')),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(strings.t('age', {'age': ''}).trim(),
                  style: body(16, color: FoxColors.muted)),
              for (var a = 3; a <= 9; a++)
                ChoiceChip(
                  label: Text('$a', style: body(16)),
                  selected: age == a,
                  showCheckmark: false,
                  onSelected: (on) => onAge(on ? a : null),
                ),
            ],
          ),
        ],
      );
}

/// Dialog for adding or editing a child. Returns (name, age) or null.
Future<(String, int?)?> showProfileDialog(
  BuildContext context,
  Strings s, {
  String name = '',
  int? age,
}) {
  final controller = TextEditingController(text: name);
  var selected = age;
  return showDialog<(String, int?)>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        content: SizedBox(
          width: 360,
          child: ProfileFields(
            strings: s,
            name: controller,
            age: selected,
            onAge: (a) => setState(() => selected = a),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(96, 48)),
            onPressed: () {
              final n = controller.text.trim();
              Navigator.pop(context, (n.isEmpty ? s.t('player') : n, selected));
            },
            child: Text(s.t('save')),
          ),
        ],
      ),
    ),
  );
}

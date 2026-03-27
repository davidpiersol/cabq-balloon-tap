import 'package:flutter/material.dart';

import '../../data/appearance_store.dart';
import '../../game/balloon_appearance.dart';

const _palette = <int>[
  0xFFE63946,
  0xFFF4A261,
  0xFF2A9D8F,
  0xFF4361EE,
  0xFF7209B7,
  0xFFFF6B35,
  0xFF9B2335,
  0xFF06A77D,
  0xFFF7C59F,
  0xFF1E3A5F,
  0xFF4CC9F0,
  0xFF5C4033,
];

Future<void> showBalloonCustomizeSheet(
  BuildContext context, {
  required BalloonAppearance initial,
  required void Function(BalloonAppearance next) onApply,
}) async {
  var draft = initial;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModal) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 24 + MediaQuery.paddingOf(context).bottom,
              top: 8,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Balloon look',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pattern and colors are saved on this device.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text('Pattern', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SegmentedButton<BalloonPattern>(
                    segments: BalloonPattern.values
                        .map(
                          (p) => ButtonSegment<BalloonPattern>(
                            value: p,
                            label: Text(
                              switch (p) {
                                BalloonPattern.solid => 'Solid',
                                BalloonPattern.stripes => 'Stripes',
                                BalloonPattern.patchwork => 'Patch',
                              },
                            ),
                          ),
                        )
                        .toList(),
                    selected: {draft.pattern},
                    onSelectionChanged: (s) {
                      setModal(() => draft = draft.copyWith(pattern: s.first));
                    },
                  ),
                  const SizedBox(height: 20),
                  _colorRow(context, 'Color A', draft.colorA, (v) {
                    setModal(() => draft = draft.copyWith(colorA: v));
                  }),
                  _colorRow(context, 'Color B', draft.colorB, (v) {
                    setModal(() => draft = draft.copyWith(colorB: v));
                  }),
                  _colorRow(context, 'Color C', draft.colorC, (v) {
                    setModal(() => draft = draft.copyWith(colorC: v));
                  }),
                  _colorRow(context, 'Basket', draft.basketArgb, (v) {
                    setModal(() => draft = draft.copyWith(basketArgb: v));
                  }),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () async {
                      await AppearanceStore.save(draft);
                      onApply(draft);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _colorRow(
  BuildContext context,
  String label,
  int selectedArgb,
  void Function(int) onPick,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _palette.map((argb) {
          final sel = argb == selectedArgb;
          return InkWell(
            onTap: () => onPick(argb),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Color(argb),
                shape: BoxShape.circle,
                border: Border.all(
                  color: sel ? Theme.of(context).colorScheme.primary : Colors.black26,
                  width: sel ? 3 : 1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 12),
    ],
  );
}

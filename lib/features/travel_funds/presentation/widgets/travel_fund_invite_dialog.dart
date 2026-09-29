import 'package:flutter/material.dart';
import '../../../../core/services/clipboard_service.dart';

Future<void> showTravelFundInviteDialog({
  required BuildContext context,
  required String inviteCode,
  required String title,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Share this invite code with your friends:'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(dialogContext).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    inviteCode,
                    style: Theme.of(dialogContext).textTheme.bodyLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Copy invite code',
                  onPressed: () async {
                    final copied = await copyTextToClipboard(inviteCode);
                    if (!dialogContext.mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          copied
                              ? 'Invite code copied'
                              : 'Copy failed. On Safari, open this page over HTTPS and try again.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_all_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}
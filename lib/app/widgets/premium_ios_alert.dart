import 'package:flutter/cupertino.dart';

/// Native iOS confirmation alert — uses system Cupertino styling on iPhone.
Future<bool?> showPremiumIosConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  bool isDestructive = false,
}) {
  return showCupertinoDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return CupertinoTheme(
        data: const CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: Color(0xFF0A84FF),
        ),
        child: CupertinoAlertDialog(
          title: Text(title),
          content: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(message),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancelLabel),
            ),
            CupertinoDialogAction(
              isDestructiveAction: isDestructive,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      );
    },
  );
}

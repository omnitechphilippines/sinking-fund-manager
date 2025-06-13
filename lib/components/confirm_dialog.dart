import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/buttons/custom_icon_button.dart';

Future<bool> showConfirmDialog({required BuildContext context, required String title, required String message, String cancelText = 'Cancel', String confirmText = 'Delete', Color? confirmColor, Color? cancelColor}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return KeyboardListener(
        autofocus: true,
        focusNode: FocusNode(),
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
          }
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                padding: const EdgeInsets.all(16),
                child: Text(title, style: Theme.of(context).textTheme.titleLarge),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(message, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CustomIconButton(onPressed: () => Navigator.of(context).pop(false), label: cancelText, backgroundColor: cancelColor ?? Colors.grey.shade700, borderRadius: 4, size: const Size(100, 40)),
                    CustomIconButton(onPressed: () => Navigator.of(context).pop(true), label: confirmText, backgroundColor: confirmColor ?? Colors.red, borderRadius: 4, size: const Size(100, 40)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  ).then((bool? value) => value ?? false);
}

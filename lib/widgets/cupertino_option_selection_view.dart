import 'package:flutter/cupertino.dart';

Future<T?> showOptionSelectionSheet<T>({
  required BuildContext context,
  required Map<String, T> options,
}) {
  return showCupertinoModalPopup<T>(
    context: context,
    builder: (BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 300.0),
      child: CupertinoActionSheet(
        title: const Text("Choose an Option"),
        actions: options.keys
            .map(
              (key) => CupertinoActionSheetAction(
                child: Text(key),
                onPressed: () {
                  Navigator.pop(context, options[key]);
                },
              ),
            )
            .toList(),
      ),
    ),
  );
}

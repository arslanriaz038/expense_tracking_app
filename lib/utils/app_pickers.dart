import 'package:expense_tracking_app/widgets/cupertino_option_selection_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class AppPickers {
  AppPickers._();

  static Future<XFile?> pickImage(BuildContext context) async {
    final ImageSource? imageSource =
        await showOptionSelectionSheet<ImageSource>(
      context: context,
      options: {
        for (final value in ImageSource.values)
          value.name[0].toUpperCase() + value.name.substring(1): value
      },
    );

    // await _imageSourceSelection(context);
    if (imageSource == null) return null;
    final ImagePicker picker = ImagePicker();
    return picker.pickImage(source: imageSource);
  }
}

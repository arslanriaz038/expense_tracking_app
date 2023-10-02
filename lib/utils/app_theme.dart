// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:sui_dhaaga_pk/gen/colors.gen.dart';

// class Themes {
//   ThemeData selectLightTheme() {
//     final Map<int, Color> color = {
//       50: ColorName.primaryColor.withOpacity(0.1),
//       100: ColorName.primaryColor.withOpacity(.2),
//       200: ColorName.primaryColor.withOpacity(.3),
//       300: ColorName.primaryColor.withOpacity(.4),
//       400: ColorName.primaryColor.withOpacity(.5),
//       500: ColorName.primaryColor.withOpacity(.6),
//       600: ColorName.primaryColor.withOpacity(.7),
//       700: ColorName.primaryColor.withOpacity(.8),
//       800: ColorName.primaryColor.withOpacity(.9),
//       900: ColorName.primaryColor.withOpacity(1),
//     };

//     return ThemeData(
//       fontFamily: 'Solway',
//       brightness: Brightness.light,
//       scaffoldBackgroundColor: ColorName.snow,
//       primaryColor: ColorName.primaryColor,
//       appBarTheme: selectAppBarTheme(),
//       primarySwatch: MaterialColor(ColorName.primaryColor.value, color),
//       textTheme: selectTextTheme(),
//       buttonTheme: const ButtonThemeData(
//         buttonColor: Colors.white,
//         shape: RoundedRectangleBorder(),
//       ),
//       textSelectionTheme:
//           const TextSelectionThemeData(cursorColor: ColorName.black),
//       iconTheme: const IconThemeData(color: ColorName.primaryColor, size: 32),
//       elevatedButtonTheme: selectOutLinedButtonTheme(),
//       // inputDecorationTheme: inputDecorationTheme(),
//       outlinedButtonTheme: outLinedButtonTheme(),
//       dividerTheme: DividerThemeData(
//         color: Colors.grey.withAlpha(500),
//       ),
//     );
//   }

//   TextTheme selectTextTheme() {
//     return TextTheme(
//       displayLarge: TextStyle(
//         fontSize: 32,
//         fontWeight: FontWeight.w700,
//         color: ColorName.black,
//       ),
//       displayMedium: TextStyle(
//         fontSize: 30,
//         fontWeight: FontWeight.w600,
//         color: ColorName.black,
//       ),
//       displaySmall: TextStyle(
//         fontSize: 24,
//         fontWeight: FontWeight.w400,
//         color: ColorName.black,
//       ),
//       headlineMedium: TextStyle(
//         fontSize: 18,
//         fontWeight: FontWeight.w400,
//         color: ColorName.black,
//       ),
//       bodyLarge: TextStyle(
//         fontWeight: FontWeight.w500,
//         fontSize: 16,
//       ),
//       bodyMedium: TextStyle(
//         fontSize: 14,
//         fontWeight: FontWeight.w400,
//         color: ColorName.black,
//       ),
//       titleMedium: TextStyle(
//         fontSize: 12,
//         fontWeight: FontWeight.w400,
//         color: ColorName.black,
//       ),
//       titleSmall: TextStyle(
//         fontSize: 10,
//         fontWeight: FontWeight.w400,
//         color: ColorName.black,
//       ),
//       labelLarge: TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.w400,
//         color: ColorName.black,
//       ),
//     );
//   }

//   AppBarTheme selectAppBarTheme() {
//     return AppBarTheme(
//       iconTheme: const IconThemeData(color: Colors.black),
//       elevation: 0,
//       systemOverlayStyle: SystemUiOverlayStyle.dark,
//       backgroundColor: ColorName.primaryColor,
//       centerTitle: true,
//       titleTextStyle: TextStyle(
//         //  fontSize: 16.sp,
//         fontWeight: FontWeight.w400,
//         color: ColorName.primaryColor,
//       ),
//     );
//   }

//   ElevatedButtonThemeData selectOutLinedButtonTheme() {
//     return ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(
//             Radius.circular(8),
//           ),
//         ),
//         backgroundColor: ColorName.primaryColor,
//         padding: EdgeInsets.symmetric(vertical: 15),
//       ),
//     );
//   }

//   OutlinedButtonThemeData outLinedButtonTheme() {
//     return OutlinedButtonThemeData(
//       style: OutlinedButton.styleFrom(
//         side: BorderSide(
//           color: ColorName.btnBorder.withOpacity(0.1),
//         ),
//         backgroundColor: Colors.white,
//         padding: EdgeInsets.symmetric(vertical: 7),
//       ),
//     );
//   }

//   InputDecorationTheme inputDecorationTheme() {
//     return InputDecorationTheme(
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(6.0),
//         borderSide: const BorderSide(color: ColorName.primaryColor),
//       ),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(6.0),
//         borderSide: const BorderSide(color: ColorName.mercury),
//       ),
//       focusColor: ColorName.primaryColor,
//       hintStyle: TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.w400,
//         color: ColorName.osloGray,
//       ),
//       labelStyle: TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.w400,
//         color: ColorName.primaryColor,
//       ),
//       fillColor: Colors.white,
//       filled: true,
//     );
//   }
// }

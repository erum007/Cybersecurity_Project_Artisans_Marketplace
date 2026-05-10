// import 'package:flutter/material.dart';

// class AppTheme {
//   static const Color primaryRed = Color(0xFFE53E2F);
//   static const Color darkRed = Color(0xFFCC3526);
//   static const Color navyBlue = Color(0xFF3D4B8F);
//   static const Color lightGrey = Color(0xFFF5F5F5);
//   static const Color mediumGrey = Color(0xFF9E9E9E);
//   static const Color darkText = Color(0xFF1A1A1A);
//   static const Color starYellow = Color(0xFFFFC107);
//   static const Color successGreen = Color(0xFF4CAF50);
//   static const Color white = Colors.white;

//   static ThemeData get theme => ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: primaryRed,
//           primary: primaryRed,
//         ),
//         scaffoldBackgroundColor: white,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: primaryRed,
//           foregroundColor: white,
//           elevation: 0,
//           centerTitle: true,
//           titleTextStyle: TextStyle(
//             color: white,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//           iconTheme: IconThemeData(color: white),
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: primaryRed,
//             foregroundColor: white,
//             minimumSize: const Size(double.infinity, 52),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             textStyle: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//         inputDecorationTheme: InputDecorationTheme(
//           filled: true,
//           fillColor: white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: const BorderSide(color: primaryRed),
//           ),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         ),
//         bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//           selectedItemColor: primaryRed,
//           unselectedItemColor: mediumGrey,
//           backgroundColor: white,
//           type: BottomNavigationBarType.fixed,
//           selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
//           unselectedLabelStyle: TextStyle(fontSize: 11),
//         ),
//         cardTheme: CardTheme(
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//             side: BorderSide(color: Colors.grey.shade200),
//           ),
//         ),
//       );
// }

import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryRed = Color(0xFFE53E2F);
  static const Color darkRed = Color(0xFFCC3526);
  static const Color navyBlue = Color(0xFF3D4B8F);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color mediumGrey = Color(0xFF9E9E9E);
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color starYellow = Color(0xFFFFC107);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color white = Colors.white;

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryRed,
          primary: primaryRed,
        ),
        scaffoldBackgroundColor: white,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryRed,
          foregroundColor: white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryRed,
            foregroundColor: white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryRed),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: primaryRed,
          unselectedItemColor: mediumGrey,
          backgroundColor: white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle:
              TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          unselectedLabelStyle: TextStyle(fontSize: 11),
        ),
        // FIXED: Changed CardTheme to CardThemeData
        cardTheme: CardThemeData(
          elevation: 0,
          color: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
      );
}

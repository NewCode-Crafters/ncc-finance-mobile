import 'package:flutter/material.dart';

class AppColors {
  static const brandPrimary = Color(0xFF004D61);
  static const brandSecondary = Color(0xFF47A138);
  static const brandSecondaryStrong = Color(0xFF2E7D32);
  static const brandTertiary = Color(0xFF22441E);
  static const brandAccent = Color(0xFFFF5031);
  static const brandAccentHover = Color(0xFFE3472C);
  static const surfaceMuted = Color.fromARGB(255, 25, 25, 26);
  static const surfaceDefault = Color(0xFF302F32);
  static const surfaceDarkGray = Color(0xFF8B8B8B);

  static const buttonPrimary = Color(0xFF47A138);
  static const buttonPrimaryHover = Color(0xFF008236);
  static const buttonSecondary = Color(0xFF004D61);
  static const buttonSecondaryHover = Color(0xFF003340);
  static const buttonTertiary = Color(0xFF22441E);
  static const buttonTertiaryHover = Color(0xFF1B2E16);

  static const success = Color(0xFF16A34A);
  static const error = Color(0xFFBF1313);
  static const warning = Color(0xFFFACC15);

  static const neutral50 = Color(0xFFFAFAFA);
  static const neutral100 = Color(0xFFF5F5F5);
  static const neutral500 = Color(0xFF525252);
  static const neutral900 = Color(0xFFBABABA);

  static const textSubtle = Color(0xFFC8C8C8);

  static const darkPurpleColor = Color(0xFFBFA1E9);
  static const lightPurpleColor = Color.fromRGBO(227, 207, 255, 1);
  static const darkGreenColor = Color(0xFF22441E);
  static const lightGreenColor = Color.fromRGBO(198, 224, 174, 1);

  static const cardSaldoGradient = LinearGradient(
    colors: [
      Color.fromRGBO(34, 68, 30, 1),
      Color.fromRGBO(116, 146, 102, 1),
      Color.fromRGBO(198, 224, 174, 1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  // Chart Colors
  static const chartBlue = Color(0xFF2567F9);
  static const chartPurple = Color(0xFF8F3CFF);
  static const chartOrange = Color(0xFFF1823D);
  static const chartMagenta = Color(0xFFFF3C82);
}

class AppTypography {
  static const fontBase = 'Inter';

  static const fontSizeXS = 13.0;
  static const fontSizeSM = 16.0;
  static const fontSizeMD = 20.0;
  static const fontSizeLG = 25.0;
  static const fontSizeXL = 40.0;

  static const fontWeightRegular = FontWeight.w400;
  static const fontWeightSemiBold = FontWeight.w600;
  static const fontWeightBold = FontWeight.w700;
}

class AppRadius {
  static const sm = 4.0;
  static const md = 8.0;
  static const lg = 16.0;
}

class AppShadow {
  static const sm = BoxShadow(
    color: Colors.black12,
    offset: Offset(0, 1),
    blurRadius: 2,
  );
  static const md = BoxShadow(
    color: Colors.black26,
    offset: Offset(0, 4),
    blurRadius: 8,
  );
  static const lg = BoxShadow(
    color: Colors.black38,
    offset: Offset(0, 8),
    blurRadius: 24,
  );
}

class AppSpacing {
  static const xs = 8.0;
  static const sm = 16.0;
  static const md = 24.0;
  static const lg = 32.0;
  static const xl = 48.0;
}

ThemeData appTheme = ThemeData(
  fontFamily: AppTypography.fontBase,
  scaffoldBackgroundColor: AppColors.surfaceDefault,
  textTheme: TextTheme(
    bodyLarge: TextStyle(
      color: AppColors.neutral100,
      fontSize: AppTypography.fontSizeSM,
      fontWeight: AppTypography.fontWeightRegular,
    ),
    bodyMedium: TextStyle(
      color: AppColors.textSubtle,
      fontSize: AppTypography.fontSizeXS,
    ),
    displayLarge: TextStyle(
      fontSize: AppTypography.fontSizeXL,
      fontWeight: AppTypography.fontWeightBold,
      color: AppColors.brandPrimary,
    ),
    displayMedium: TextStyle(
      fontSize: AppTypography.fontSizeLG,
      fontWeight: AppTypography.fontWeightSemiBold,
      color: AppColors.brandSecondary,
    ),
    // Adicione outros estilos conforme necessário
  ),
  colorScheme: ColorScheme(
    primary: AppColors.brandPrimary,
    secondary: AppColors.brandSecondary,
    surface: AppColors.surfaceDefault,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.neutral900,
    onError: Colors.white,
    brightness: Brightness.light,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: AppColors.buttonTertiary,
    hoverColor: AppColors.buttonTertiaryHover,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.buttonPrimary,
      onPrimary: AppColors.buttonPrimary,
      secondary: AppColors.buttonSecondary,
      onSecondary: AppColors.buttonSecondary,
      error: AppColors.error,
      onError: AppColors.error,
      surface: AppColors.surfaceDefault,
      onSurface: AppColors.neutral900,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonTertiary,
      foregroundColor: Colors.white,
      textStyle: TextStyle(
        fontSize: AppTypography.fontSizeSM,
        fontWeight: AppTypography.fontWeightSemiBold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.surfaceDefault,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.neutral100),
    titleTextStyle: TextStyle(
      color: AppColors.neutral100,
      fontSize: AppTypography.fontSizeLG,
      fontWeight: AppTypography.fontWeightBold,
    ),
  ),
  useMaterial3: true,
);

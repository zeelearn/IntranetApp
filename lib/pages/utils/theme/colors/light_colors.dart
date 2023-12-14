import 'package:Intranet/pages/helper/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LightColors  {
  static const Color kLightYellow = Color(0xFFFFF9EC);
  static const Color kLightYellow2 = Color(0xFFFFE4C7);
  static const Color kDarkYellow = Color(0xFFF9BE7C);
  static const Color kPalePink = Color(0xFFFED4D6);

  static const Color kRed = Color(0xFFE46472);
  static const Color kLavender = Color(0xFFD5E4FE);
  static const Color kBlue = Color(0xFF6488E4);
  static const Color kLightGreen = Color(0xFFD9E6DC);
  static const Color kGreen = Color(0xFF309397);
  static const Color kYallow = Color(0xFF309397);

  static const Color kDarkBlue = Color(0xFF0D253F);
  static const Color kLightBlue = Color(0xFFE8F5E9);
  static const Color kLightOrange = Color(0xFFFFE0B2);
  static const Color kDarkOrange = Color(0xFFFFCC80);
  static const Color kLightFULLDAY = Color(0xFFF1F8E9);
  static const Color kFULLDAY_BUTTON = Color(0xFFB2EBF2);
  static const Color kAbsent = Color(0xFFFBE9E7);
  static const Color kAbsent_BUTTON = Color(0xFFFFCDD2);
  static const Color kLightRed = Color(0xFFFFEBEE);

  static const Color kLightGray = Color(0xFFF5F5F5);
  static const Color kLightGray1 = Color(0xFFE0E0E0);
  static const Color white = Colors.white;

  static const Color kLightGrayM = Color.fromRGBO(242, 243, 244, 95);
  static const Color kLightRedMaterial = Color.fromRGBO(250, 219, 216, 95);
  static const Color kLightGreenMaterial = Color.fromRGBO(169, 223, 191 , 71);
  static const Color kLightBlueMaterial = Color.fromRGBO(52, 152, 219 , 53);


  static const Color TextColor = Color.fromARGB(255, 14,44, 83);
  //static const TextStyle pentemindTextStyle = TextStyle(color: TextColor,fontFamily: 'roboto', fontSize: 16);
  static TextStyle textHeaderStyle = GoogleFonts.roboto(
    fontSize: 16.0,
    color: Color.fromARGB(255, 14,44, 83),
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  static TextStyle textHeaderStyleWhite = GoogleFonts.roboto(
    fontSize: 16.0,
    color: Colors.white,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static TextStyle hintTextStyle = GoogleFonts.roboto(
    fontSize: 16.0,
    color: Color(0xFF4B39EF),
    fontWeight: FontWeight.normal,
    backgroundColor: LightColors.kAbsent,
    height: 1.5,
  );

  static TextStyle textHeaderStyle16 = GoogleFonts.roboto(
    fontSize: 16.0,
    color: LightColors.TextColor,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static TextStyle textHeaderStyle13 = GoogleFonts.roboto(
    fontSize: 13.0,
    color: LightColors.TextColor,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static TextStyle textHeaderStyle13Selected = GoogleFonts.roboto(
    fontSize: 13.0,
    color: Colors.white,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  static TextStyle textHeaderStyle13Unselected = GoogleFonts.roboto(
    fontSize: 13.0,
    color: Colors.white24,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  static TextStyle textbigStyle = GoogleFonts.roboto(
    fontSize: 18.0,
    color: LightColors.TextColor,
  );
  static TextStyle textSmallStyle = GoogleFonts.albertSans(
    fontSize: 12.0,
    color: LightColors.kDarkBlue,
    fontWeight: FontWeight.normal,
    height: 1,
  );

  static TextStyle textSmallHightliteStyle = GoogleFonts.albertSans(
    fontSize: 12.0,
    color: LightColors.kLightBlueMaterial,
    fontWeight: FontWeight.normal,
    height: 1,
  );
  static TextStyle textvSmallStyle = GoogleFonts.roboto(
    fontSize: 8.0,
    color: LightColors.TextColor,
    fontWeight: FontWeight.normal,
    height: 1,
  );

  static TextStyle textsubtitle = GoogleFonts.roboto(
    fontSize: 12.0,
    color: LightColors.kLightGrayM,
    fontWeight: FontWeight.normal,
    height: 1,
  );
  static TextStyle textStyle = GoogleFonts.roboto(
    fontSize: 15.0,
    color: LightColors.TextColor,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );
  static TextStyle textbuttonStyle = GoogleFonts.roboto(
    fontSize: 18.0,
    color: Colors.white,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );
  static TextStyle subTextStyle = GoogleFonts.poppins(
    color: LightColors.TextColor,
    fontSize: 10.0,
  )/*GoogleFonts.roboto(
    fontSize: 10.0,
    color: LightColors.TextColor,
    fontWeight: FontWeight.w600,
    height: 1.5,
  )*/;
  static TextStyle smallTextStyle = GoogleFonts.poppins(
    color: LightColors.TextColor,
    fontSize: 10.0,
  );
  static TextStyle titleTextStyle = GoogleFonts.poppins(
    color: LightColors.TextColor,
    fontSize: 12.0,
  );

  static TextStyle titleWhiteTextStyle = GoogleFonts.poppins(
    color: Colors.white,
    fontSize: 14.0,
  );

  static TextStyle headerTitleSelected = GoogleFonts.poppins(
    color: kPrimaryLightColor,
    fontSize: 16.0,
  );
  static TextStyle headerTilte = GoogleFonts.poppins(
    color: Colors.black,
    fontSize: 16.0,
  );

  static TextStyle subWhiteTextStyle = GoogleFonts.poppins(
    color: Colors.white,
    fontSize: 12.0,
  );
  static TextStyle titleRedTextStyle = GoogleFonts.poppins(
    color: Colors.red,
    fontSize: 12.0,
  );
  static TextStyle subtitleRedTextStyle = GoogleFonts.poppins(
    color: LightColors.kRed,
    fontSize: 12.0,
  );
  static TextStyle absentRoundedStyle = GoogleFonts.roboto(
    fontSize: 12.0,
    color: Colors.white,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );
}
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/pages/helper/LightColor.dart';

class SignInOneSocialButton extends StatelessWidget {
  SignInOneSocialButton(
      {Key? key, required this.size, required this.iconPath, required this.text})
      : super(key: key);
  late Size size;
  String iconPath='';
  String text='';
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 14,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40.0),
        border: Border.all(
          width: 1.0,
          color: LightColor.primary_color,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 1,
            child: SvgPicture.asset(iconPath),
          ),
          Expanded(
            flex: 2,
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14.0,
                color: LightColor.primary_color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
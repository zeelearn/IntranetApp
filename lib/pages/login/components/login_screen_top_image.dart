import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../helper/constants.dart';


class LoginScreenTopImage extends StatelessWidget {
  const LoginScreenTopImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            Expanded(
              child: Image.asset('assets/icons/app_logo.png',height: 100,),//SvgPicture.asset("assets/icons/app_logo.png"),
            ),
            const Spacer(),
          ],
        ),
        SizedBox(height: defaultPadding * 2),
      ],
    );
  }
}
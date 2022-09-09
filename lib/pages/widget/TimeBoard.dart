import 'package:flutter/material.dart';
import 'package:intranet/pages/utils/theme/colors/light_colors.dart';

import '../helper/utils.dart';

class TimeBoard extends StatelessWidget {
  final String hour;
  final String minute; // should contains PM or AM
  final page;
  final bool isCompleted;

  const TimeBoard({
    Key? key,
    required this.hour,
    required this.minute,
    required this.page,
    required this.isCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 80,
      margin: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        color:
        (page == TaskPageStatus.active) ? LightColors.kDarkYellow : Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '$hour',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Open Sans',
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: (page == TaskPageStatus.active)
                  ? Colors.lime
                  : Colors.orange,
            ),
          ),
          Text(
            '$minute',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Open Sans',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: (page == TaskPageStatus.active)
                  ? Colors.black
                  : Colors.black45,
            ),
          )
        ],
      ),
    );
  }
}

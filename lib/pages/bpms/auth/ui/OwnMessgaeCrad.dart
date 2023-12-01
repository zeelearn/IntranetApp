import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../api/response/bpms/get_comments_response.dart';
import '../../../utils/theme/colors/light_colors.dart';

class OwnMessageCard extends StatelessWidget {
  const OwnMessageCard({Key? key, required this.commentModel,required this.time, required this.isSelf}) : super(key: key);
  final CommentModel commentModel;
  final String time;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSelf ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
          minWidth: 150,
        ),
        child: Column(
          children: [
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              color: isSelf ? LightColors.kLightBlue : LightColors.kLightYellow /*Color(0xffdcf8c6)*/,
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 30,
                      top: 10,
                      bottom: 20,
                    ),
                    child: Text(
                      commentModel.comment.length<6? '              ${commentModel.comment}' : commentModel.comment,
                      style: GoogleFonts.roboto(

                        fontSize: 12.0,
                        color: Colors.black,
                        height: 1,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 0,
                    child: Row(
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.done_all,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            /*!isSelf ? SizedBox(height: 0,width: 0,) :*/
            Text('By - ${commentModel.createduser}',style: LightColors.smallTextStyle,)
          ],
        ),
      ),
    );
  }
}

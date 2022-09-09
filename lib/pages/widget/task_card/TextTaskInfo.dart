import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:styled_widget/styled_widget.dart';
import '../../helper/utils.dart';
import '../TimeBoard.dart';
import 'CardColor.dart';

class TextTaskInfo extends StatelessWidget {
  final TaskPageStatus page;
  final String title;
  final String note;
  final DateTime date;
  final bool isCompleted;

  const TextTaskInfo({
    Key? key,
    required this.page,
    required this.title,
    required this.note,
    required this.date,
    required this.isCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CardColor taskCardColors = CardColor(page, isCompleted);
    String dateFormat = DateFormat('yyyy MMMM dd').format(date);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Card(
        child: Row(
          children: [
            TimeBoard(
              page: TaskPageStatus.active,
              isCompleted: isCompleted,
              hour: date.day.toString(),
              minute: DateFormat("MMM").format(date),
            ),
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,

                  child:  Text(
                    title,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'Open Sans',
                      color: Colors.black87,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  padding: EdgeInsets.only(bottom: 2.0),
                  child: Text(
                    note,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Open Sans',
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            )

          ],
        ),
      ),
    );
  }
}

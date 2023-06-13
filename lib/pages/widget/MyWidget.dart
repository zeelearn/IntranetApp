import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intranet/pages/helper/LightColor.dart';
import 'package:intranet/pages/utils/theme/colors/light_colors.dart';

class MyWidget{


  static getInputDecoratino(String value){
    return InputDecoration(
      fillColor: Colors.white,
      border: InputBorder.none,
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          borderSide: BorderSide(color: Colors.blue)),
      filled: true,
      contentPadding:
      EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
      labelText: value,
    );
  }

  Widget emailTextField(Size size,TextEditingController _controller) {
    return Container(
      alignment: Alignment.center,
      height: size.height / 11,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          width: 1.0,
          color: const Color(0xFFEFEFEF),
        ),
      ),
      child: TextField(
        controller: _controller,
        style: GoogleFonts.inter(
          fontSize: 16.0,
          color: const Color(0xFF15224F),
        ),
        maxLines: 1,
        cursorColor: const Color(0xFF15224F),
        decoration: InputDecoration(
            labelText: 'Email/ Phone number',
            labelStyle: GoogleFonts.inter(
              fontSize: 12.0,
              color: const Color(0xFF969AA8),
            ),
            border: InputBorder.none),
      ),
    );
  }

  getTextPadding(){
    return const EdgeInsets.only(left: 15,right: 15);
  }

  Widget richText(double fontSize,String value) {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          fontSize: fontSize,
          color: LightColor.black,
          letterSpacing: 2,
          height: 1.03,
        ),
        children:  [
          TextSpan(
            text: value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }



  Widget normalTextField(BuildContext context,String label,TextEditingController _controller) {
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height / 14,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          width: 1.0,
          color: LightColor.titleTextColor,
        ),
      ),
      child: TextField(
        controller: _controller,
        style: GoogleFonts.robotoMono(
          fontStyle: FontStyle.normal,
          fontSize: 20.0,
          color: LightColor.primarydark_color,
        ),
        maxLines: 1,
        cursorColor: const Color(0xFF15224F),
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.perm_identity),
            filled: true,
            labelText: label,
            labelStyle: GoogleFonts.inter(
              fontSize: 12.0,
              color: LightColor.black,
            ),
            border: InputBorder.none),
      ),
    );
  }

  Widget normalTextAreaField(BuildContext context,String label,TextEditingController _controller) {
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height / 10,
      padding: getTextPadding(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          width: 1.0,
          color: LightColor.titleTextColor,
        ),
      ),
      child: TextField(
        controller: _controller,
        style: GoogleFonts.robotoMono(
          fontStyle: FontStyle.normal,
          fontSize: 18.0,
          color: LightColor.titleTextColor,
        ),
        maxLines: 1,
        cursorColor: const Color(0xFF15224F),
        decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.inter(
              fontSize: 12.0,
              color: LightColor.black,
            ),
            border: InputBorder.none),
      ),
    );
  }

  getDateTime(BuildContext context,String label, TextEditingController controller,
      DateTime minDate,DateTime maxDate) {
    return TextField(
        style: TextStyle(color: LightColor.titleTextColor),
        controller: controller, //editing controller of this TextField
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                borderSide: BorderSide(color: LightColors.kLavender)),
            icon: Icon(Icons.calendar_today), //icon of text field
            labelText: label //label text of field
        ),
        readOnly: true, //set it true, so that user will not able to edit text
        onTap: () async {

          DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: minDate,
              //DateTime.now() - not to allow to choose before today.
              lastDate: maxDate);

          if (pickedDate != null) {
            print(
                pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
            String formattedDate = DateFormat('dd-MMM-yyyy').format(pickedDate);
            controller.text = formattedDate;
            print(formattedDate); //formatted date output using intl package =>  2021-03-16
            /*setState(() {
              dateInput.text =
                  formattedDate; //set output date to TextField value.
            });*/
          } else {}

          /*DatePicker.showDatePicker(context,
              showTitleActions: true,
              minTime: minDate,
              maxTime: maxDate,
              theme: DatePickerTheme(
                  headerColor: LightColors.kLightYellow,
                  backgroundColor: LightColors.kLightBlue,
                  itemStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                  doneStyle: TextStyle(color: Colors.black, fontSize: 16)),
              onChanged: (date) {
                String formattedDate = DateFormat('yyyy-MM-dd').format(date);
                controller.text = formattedDate;
                print('change $date in time zone ' +
                    date.timeZoneOffset.inHours.toString());
              }, onConfirm: (date) {
                print('confirm $date');
              }, currentTime: DateTime.now(), locale: LocaleType.en);*/
        });
  }

  getTime(BuildContext context,String label, TextEditingController controller,
      DateTime minDate,DateTime maxDate) {
    return TextField(
      style: TextStyle(color: Colors.black),
        controller: controller, //editing controller of this TextField
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                borderSide: BorderSide(color: LightColors.kLavender)),
            icon: Icon(Icons.timer), //icon of text field
            labelText: label //label text of field
        ),
        readOnly: true, //set it true, so that user will not able to edit text
        onTap: () async {

        });
  }


  _selectTime(BuildContext context,TextEditingController controller) async {
    TimeOfDay selectedTime = TimeOfDay.now();
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if(timeOfDay != null && timeOfDay != selectedTime)
    {
      controller.text = '${timeOfDay.hour}:${timeOfDay.minute}';
    }
  }

  MyButtonPadding(){
    return EdgeInsets.only(top: 2,bottom: 2,left: 10,right: 10);
  }



}
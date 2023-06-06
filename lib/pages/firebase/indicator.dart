import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IconIndicator extends StatelessWidget {
  const IconIndicator({
    Key? key,
    required this.iconData,
    required this.size,
  }) : super(key: key);

  final IconData iconData;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 30,
              width: 30,
              child: Icon(
                iconData,
                size: size,
                color: const Color(0xFF9E3773).withOpacity(0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class ContainerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              'now - 17:30',
              style: GoogleFonts.lato(
                fontSize: 18,
                color: const Color(0xFFF4A5CD),
              ),
            ),
            Text(
              'Sunny',
              style: GoogleFonts.lato(
                fontSize: 30,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w800,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Humidity 40%',
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: const Color(0xFF4A448F).withOpacity(0.8),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  '30°C',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: const Color(0xFF4A448F).withOpacity(0.8),
                    fontWeight: FontWeight.w800,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class Sun extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            blurRadius: 25,
            spreadRadius: 20,
          ),
        ],
        shape: BoxShape.circle,
        color: Colors.white,
      ),
    );
  }
}
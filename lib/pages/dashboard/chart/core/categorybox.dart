import 'package:flutter/material.dart';

class CategoryBox extends StatelessWidget {
  final List<Widget> children;
  final Widget suffix;
  final String title;

  const CategoryBox({
    Key? key,
    required this.suffix,
    required this.children,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left:18,right:18,top: 10,),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
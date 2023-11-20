import 'package:flutter/material.dart';

import '../../api/response/bpms/project_task.dart';

class PathBar extends StatelessWidget implements PreferredSizeWidget {
  final List<ProjectTaskModel> paths;
  final Function(int) onChanged;
  final IconData? icon;

  PathBar({
    Key? key,
    required this.paths,
    required this.onChanged,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: paths.length,
          itemBuilder: (BuildContext context, int index) {
            String i = paths[index].path;
            List splited = i.split('/');
            if (index == -1) {
              return IconButton(
                icon: Icon(
                  Icons.home,
                  color: index == paths.length - 1
                      ? Theme.of(context).hintColor
                      : Theme.of(context).textTheme.headline6!.color,
                ),
                onPressed: () => onChanged(index),
              );
            }
            return InkWell(
              onTap: () => onChanged(index),
              child: Container(
                height: 40,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${splited[splited.length - 1]}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: index == paths.length - 1
                            ? Theme.of(context).hintColor
                            : Theme.of(context).textTheme.headline6!.color,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => onChanged(-1),
            );;//Image.asset('assets/icons/ic_arrow_right.png');
          },
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(20.0);
}

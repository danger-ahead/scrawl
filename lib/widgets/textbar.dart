import 'package:flutter/material.dart';

class TextBar extends StatefulWidget {
  @override
  _TextBarState createState() => _TextBarState();
}

class _TextBarState extends State<TextBar> {

  bool isDark = false;
  Brightness brightness;
  @override
  Widget build(BuildContext context) {
    brightness = MediaQuery.platformBrightnessOf(context);
    isDark = (brightness == Brightness.dark);
    return InkWell(
      child: Container(
        width: 500.0,
        margin: EdgeInsets.only(top: 10.0),
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: BoxDecoration(
          // color: Colors.black54,
          color: isDark ? Colors.grey[800] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5.0,
            ),
          ],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Write a note'),
            Row(
              children: [
                IconButton(
                    onPressed: () {}, icon: Icon(Icons.check_box_outlined)),
                IconButton(onPressed: () {}, icon: Icon(Icons.image_outlined)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

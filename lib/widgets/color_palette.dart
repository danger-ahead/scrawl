import 'package:flutter/material.dart';

class ColorPalette extends StatelessWidget {
  final Function onTap;
  final Color color;
  final bool isSelected;

  const ColorPalette(
      {Key? key,
      required this.onTap,
      required this.color,
      required this.isSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;
    return GestureDetector(
      child: new Container(
        margin: EdgeInsets.all(8.0),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
            color: this.color,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
                color: darkModeOn ? Colors.white12 : Colors.black26)),
        child: isSelected ? Icon(Icons.check) : Container(),
      ),
      onTap: () => onTap(),
    );
  }
}

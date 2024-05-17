import 'package:flutter/material.dart';

class GridItemWidget extends StatelessWidget {
  final List<String> contents;
  final String color;
  final double height, width, radius;
  GridItemWidget(
      {Key key,
      @required this.contents,
      @required this.color,
      @required this.height,
      @required this.width,
      @required this.radius})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(children: [
      Container(
          width: width / 2.6,
          child: Text(contents.first,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          decoration: BoxDecoration(
              color: generateDarkShade(color),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(radius))),
          padding: EdgeInsets.only(
              left: width / 40,
              right: width * 2 / (contents.first.length),
              top: height / 80,
              bottom: height / 100)),
      Container(
          width: width / 2.6,
          decoration: BoxDecoration(
              color: generateLightShade(color),
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(radius))),
          child: Column(
              children: [
                //Container(),

                Container(
                    child: Text(
                        contents[((contents.indexOf(contents.first) +
                                    contents.indexOf(contents.last)) /
                                2)
                            .floor()],
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 12)),
                    padding: EdgeInsets.symmetric(vertical: height / 200)),
                Container(
                    child: Text(contents.last,
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 12)),
                    padding: EdgeInsets.symmetric(vertical: height / 200))
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start),
          padding: EdgeInsets.only(
              left: width / 50,
              right: width * 1.8 / (contents.last.length),
              top: height / 100,
              bottom: height / 80))
    ], mainAxisAlignment: MainAxisAlignment.start);
  }

  Color generateLightShade(String color) {
    if (color == null || color == "")
      return Color(0);
    else {
      final vb = color.trim().split("#").last;
      return Color(int.parse("0x99" + vb));
    }
  }

  Color generateDarkShade(String color) {
    if (color == null || color == "")
      return Color(0);
    else {
      final vb = color.trim().split("#").last;
      return Color(int.parse("0xff" + vb));
    }
  }
}

import 'dart:math';

import 'package:flutter/material.dart';

class MySwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const MySwitch({Key key, this.value, this.onChanged, this.activeColor})
      : super(key: key);

  @override
  MySwitchState createState() => MySwitchState();
}

class MySwitchState extends State<MySwitch>
    with SingleTickerProviderStateMixin {
  Animation _circleAnimation;
  AnimationController _animationController;
  double get height => MediaQuery.of(context).size.height;
  double get width => MediaQuery.of(context).size.width;
  double get size => sqrt(pow(height, 2) + pow(width, 2));

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 60));
    _circleAnimation = AlignmentTween(
            begin: widget.value ? Alignment.centerRight : Alignment.centerLeft,
            end: widget.value ? Alignment.centerLeft : Alignment.centerRight)
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.linear));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            if (_animationController.isCompleted) {
              _animationController.reverse();
            } else {
              _animationController.forward();
            }
            // print(currentTab);
            // print(a);
            widget.value == false
                ? widget.onChanged(true)
                : widget.onChanged(false);
            // widget.onChanged(widget.value);
          },
          child: Container(
            width: width / 6.4,
            height: height / 32,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size / 40),
                color: _circleAnimation.value == Alignment.centerLeft
                    ? Colors.grey
                    : widget.activeColor),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 640),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _circleAnimation.value == Alignment.centerRight
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: width / 64),
                          child: Text(
                            'ON',
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.8),
                          ),
                        )
                      : Container(),
                  Align(
                    alignment: _circleAnimation.value,
                    child: Container(
                      width: size / 50,
                      height: size / 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _circleAnimation.value == Alignment.centerLeft
                              ? Color(0xffa11414)
                              : Colors.white),
                    ),
                  ),
                  _circleAnimation.value == Alignment.centerLeft
                      ? Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: width / 100),
                          child: Text(
                            'OFF',
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.8),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

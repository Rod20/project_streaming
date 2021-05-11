import 'dart:ui';

import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final Image iconButton;
  final String textButton;
  final VoidCallback onPressed;

  LoginButton(
      {Key key,
        this.iconButton,
        @required this.textButton,
        @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50.0,
        child: OutlineButton(
          color: Colors.white,
          splashColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ), // Round// edRectangleBorder
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: iconButton != null
                    ? Container(
                  height: 28.0,
                  child: iconButton,
                )
                    : null,
              ),
              Center(
                child: Text(
                  textButton,
                  style: Theme.of(context).textTheme.button.merge(
                    TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.normal,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              )
            ],
          ), // Text
          onPressed: onPressed, // onPressed
        ));
  }
}

import 'package:flutter/material.dart';

double getFullHeight(MediaQueryData mediaQuery) {
  final padding = mediaQuery.padding;
  var keyboardHeight = mediaQuery.viewInsets.bottom;

  return mediaQuery.size.height -
      padding.top - // height of status bar (your battery life and stuff)
      kToolbarHeight - // height of the toolbar (i.e. the AppBar)
      keyboardHeight;
}

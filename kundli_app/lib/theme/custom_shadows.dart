import 'package:flutter/material.dart';

class CustomShadows {
  static List<BoxShadow> get cardShadow => [
        const BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.02),
          offset: Offset(0, 1),
          blurRadius: 3,
          spreadRadius: 0,
        ),
        const BoxShadow(
          color: Color.fromRGBO(27, 31, 35, 0.15),
          offset: Offset(0, 0),
          blurRadius: 0,
          spreadRadius: 1,
        ),
      ];
}

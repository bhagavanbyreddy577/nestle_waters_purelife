import 'package:flutter/material.dart';

class NHelperWidgets {

  static Widget showLoading(Color? color){
    return Center(
      child: CircularProgressIndicator(
        color: color ?? Colors.blueAccent,
      ),
    );
  }


}
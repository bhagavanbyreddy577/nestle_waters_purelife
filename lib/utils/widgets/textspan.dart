import 'package:flutter/material.dart';

class NTextspan extends StatelessWidget {

  final String title;
  const NTextspan({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  WidgetSpan(
                    child: Text(
                      title,
                    ),
                  ),
                  WidgetSpan(
                    child: Text(
                      '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
   }
}
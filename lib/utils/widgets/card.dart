import 'package:flutter/material.dart';

class CustomCardWidget extends StatelessWidget {

  /// The child widget to be displayed inside the card
  final Widget? child;

  /// Background color of the card
  final Color? backgroundColor;

  /// Border radius of the card
  final BorderRadius? borderRadius;

  /// Elevation of the card (shadow depth)
  final double? elevation;

  /// Padding inside the card
  final EdgeInsetsGeometry? padding;

  /// Width of the card
  final double? width;

  /// Height of the card
  final double? height;

  /// Border color of the card
  final Color? borderColor;

  /// Border width of the card
  final double? borderWidth;

  /// Gradient to be applied as background (optional)
  final Gradient? gradient;

  /// Callback for when the card is tapped
  final VoidCallback? onTap;

  /// Constructor for CustomCardWidget
  const CustomCardWidget({
    super.key,
    this.child,
    this.backgroundColor,
    this.borderRadius,
    this.elevation = 4.0,
    this.padding,
    this.width,
    this.height,
    this.borderColor,
    this.borderWidth,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          // Apply gradient if provided, otherwise use background color
          gradient: gradient,
          color: gradient == null ? (backgroundColor ?? Colors.white) : null,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          border: borderColor != null
              ? Border.all(
            color: borderColor!,
            width: borderWidth ?? 1.0,
          )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: elevation ?? 4.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

// TODO: Usage example (Need to remove in production)

/*
*
* CustomCardWidget(
              backgroundColor: Colors.blue[100],
              borderRadius: BorderRadius.circular(20),
              elevation: 6.0,
              borderColor: Colors.blue,
              borderWidth: 2.0,
              width: 300,
              onTap: () {
                // Add tap functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Card Tapped!')),
                );
              },
              child: const Column(
                children: [
                  Text(
                    'Customized Card',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('With multiple customizations'),
                ],
              ),
            )
* */
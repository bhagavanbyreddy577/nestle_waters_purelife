import 'package:flutter/material.dart';

class Destination {
  const Destination({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const destinations = [
  Destination(label: 'Home', icon: Icons.home_outlined),
  Destination(label: 'Subscription', icon: Icons.subscriptions_outlined),
  Destination(label: 'Cart', icon: Icons.shopping_cart_outlined),
  Destination(label: 'MyAccount', icon: Icons.account_box_outlined),
];
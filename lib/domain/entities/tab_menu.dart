import 'package:flutter/material.dart';

class TabMenuEntity {
  final String name;
  final IconData icon;
  final Function()? onTap;
  TabMenuEntity({required this.name, required this.icon, required this.onTap});
}

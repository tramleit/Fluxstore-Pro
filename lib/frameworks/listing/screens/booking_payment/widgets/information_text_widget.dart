import 'package:flutter/material.dart';

class InformationTextWidget extends StatelessWidget {
  final TextEditingController controller;
  final String title;

  const InformationTextWidget({
    Key? key,
    required this.controller,
    required this.title,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      margin: const EdgeInsets.only(top: 10.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(width: 1, color: Theme.of(context).primaryColor)),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(border: InputBorder.none, labelText: title),
      ),
    );
  }
}

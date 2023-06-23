import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CalendarPlannerEmployeeCard extends StatelessWidget {
  final String? employeeName;
  final String? imageUrl;
  const CalendarPlannerEmployeeCard({Key? key, this.employeeName, this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          child: Image.asset(
            imageUrl!,
            // fit: BoxFit.cover,
          ),
        ),
        Text(
          employeeName!,
          style: TextStyle(fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}

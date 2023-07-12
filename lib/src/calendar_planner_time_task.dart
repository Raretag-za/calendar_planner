import 'package:flutter/material.dart';
import 'package:time_planner/time_planner.dart';

class MyTimePlannerTask {
  final Color? color;
  final TimePlannerDateTime dateTime;
  final int minutesDuration;
  final int daysDuration;
  final String employeeName;
  final VoidCallback? onTap;
  final Widget? child;

  MyTimePlannerTask({
    required this.color,
    required this.dateTime,
    required this.minutesDuration,
    required this.daysDuration,
    required this.employeeName,
    this.onTap,
    this.child,
  });

  TimePlannerTask toTimePlannerTask(){
    return TimePlannerTask
      (
        color: color,
        minutesDuration: minutesDuration,
        dateTime: dateTime,
        daysDuration: daysDuration,
        onTap: onTap,
        child: child,
    );
  }
}
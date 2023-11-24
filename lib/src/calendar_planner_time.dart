import 'package:flutter/material.dart';
import 'package:calendar_planner/config/global_config.dart' as config;

/// Show the hour for each row of time planner
class CalendarPlannerTime extends StatelessWidget {
  /// Text it will be show as hour
  final String? time;
  final bool? setTimeOnAxis;

  /// Show the hour for each row of time planner
  const CalendarPlannerTime({
    Key? key,
    this.time,
    this.setTimeOnAxis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: config.cellHeight!.toDouble() - 1,
      width: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
        child: setTimeOnAxis! ? Text(time!) : Center(child: Text(time!)),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';

import 'calendar_planner_style.dart';
import 'calendar_planner_task.dart';
import 'calendar_planner_title.dart';

class CalendarPlanner extends StatefulWidget {

  final int startHour;

  /// Time end at this hour, max value is 23
  final int endHour;

  /// Create days from here, each day is a TimePlannerTitle.
  ///
  /// you should create at least one day
  final List<CalendarPlannerTitle> headers;

  /// List of widgets on time planner
  final List<CalendarPlannerTask>? tasks;

  /// Style of time planner
  final CalendarPlannerStyle? style;

  /// When widget loaded scroll to current time with an animation. Default is true
  final bool? currentTimeAnimation;

  /// Whether time is displayed in 24 hour format or am/pm format in the time column on the left.
  final bool use24HourFormat;

  //Whether the time is displayed on the axis of the tim or on the center of the timeblock. Default is false.
  final bool setTimeOnAxis;

  const CalendarPlanner({Key? key,
    required this.startHour,
    required this.endHour,
    required this.headers,
    this.tasks,
    this.style,
    this.use24HourFormat = false,
    this.setTimeOnAxis = false,
    this.currentTimeAnimation}) : super(key: key);

  @override
  State<CalendarPlanner> createState() => _CalendarPlannerState();
}

class _CalendarPlannerState extends State<CalendarPlanner> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

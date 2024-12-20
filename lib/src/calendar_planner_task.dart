import 'package:calendar_planner/src/calendar_planner_time_task.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_planner/time_planner.dart';

class CalendarPlannerTask extends StatelessWidget {
  final List<MyTimePlannerTask> tasks;
  final List<String> employees;
  final int startHour;
  final int endHour;
  final VoidCallback? onTap;

  CalendarPlannerTask({
    required this.tasks,
    required this.employees,
    required this.startHour,
    required this.endHour,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return
      GestureDetector(
        onTap:  onTap ?? () {},
        child: TimePlanner(
          startHour: startHour,
          endHour: endHour,
          use24HourFormat: true,
          headers: List.generate(employees.length, (index){
            return TimePlannerTitle(
                date: "",
                title: employees[index]
            );
          }),
          style: TimePlannerStyle(
            showScrollBar: true,
            cellWidth:
            employees.length > 1
                ? (MediaQuery.of(context).size.width * 0.7).toInt()
                : (MediaQuery.of(context).size.width).toInt(),
          ),
          tasks: tasks.map((task)=> task.toTimePlannerTask()).toList(),
        ),
      );
  }
}
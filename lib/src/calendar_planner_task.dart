import 'package:calendar_planner/src/calendar_planner_time_task.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_planner/time_planner.dart';

class CalendarPlannerTask extends StatelessWidget {
  final List<MyTimePlannerTask> tasks;
  final List<String> employees;
  final int startHour;
  final int endHour;

  CalendarPlannerTask({
    required this.tasks,
    required this.employees,
    required this.startHour,
    required this.endHour,
});

  @override
  Widget build(BuildContext context) {
    return
      TimePlanner(
        startHour: startHour,
        endHour: endHour,
        headers: List.generate(employees.length, (index){
          return TimePlannerTitle(
              date: "",
              title: employees[index]
          );
        }),
        style: TimePlannerStyle(
        showScrollBar: true,
            cellWidth: 200,
    ),
        tasks: tasks.map((task)=> task.toTimePlannerTask()).toList(),
    );
  }
}

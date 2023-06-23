
import 'package:flutter/material.dart';

import 'calendar_planner_time.dart';

class CalendarPlannerColumn extends StatelessWidget {
  const CalendarPlannerColumn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for(int i = 0; i < 10; i++)
          const CalendarPlannerTime(time:'01:00',setTimeOnAxis: true,),
          // Column(
          //   children: [
          //     const CalendarPlannerTime(time:'01:00',setTimeOnAxis: true,),
          //     const Divider(height: 1,)
          //   ],
          // ),
      ],
    );
  }
}

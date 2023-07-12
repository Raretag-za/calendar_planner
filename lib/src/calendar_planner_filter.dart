import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';


class CalendarPlannerFilter extends StatefulWidget {
  const CalendarPlannerFilter({Key? key}) : super(key: key);

  @override
  _CalendarPlannerFilterState createState() => _CalendarPlannerFilterState();
}

class _CalendarPlannerFilterState extends State<CalendarPlannerFilter> {
  String selectedValue = 'Hair And Beauty';
  DateTime selectedDate = DateTime.now();
  TextEditingController customerController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  void selectBackDate(){
    DateTime currentDate = DateTime.now();
    if (selectedDate.isAfter(currentDate)) {
    setState(() {
      selectedDate = selectedDate.subtract(Duration(days: 1));
    });
    }
  }

  void selectNextDate(){
    setState(() {
      selectedDate = selectedDate.add(Duration(days: 1));
    });
  }
  void showAppointmentForm(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        TimeOfDay ? selectedTime;
        TextEditingController timeController = TextEditingController();
        Future<Null> selectTime() async {
          final TimeOfDay ? pickedTime = await showTimePicker(
              context: context,
              initialTime: selectedTime ?? TimeOfDay.now(),
              builder: (BuildContext context, Widget? child){
                return MediaQuery
                  (
                    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                    child: child!
                );
              }

          );
          if (pickedTime != null) {
            setState(() {
              selectedTime = TimeOfDay(hour: pickedTime.hour, minute: pickedTime.minute);
              timeController.text = selectedTime!.format(context);
            });
          }
        }
        return AlertDialog(
          title: Text('Add Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add your appointment form fields here
              TextField(
                decoration: InputDecoration(labelText: 'Date'),
                readOnly: true,
                controller: TextEditingController(text: DateFormat('EEEE, d MMMM yyyy').format(selectedDate)),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Customer*'),
                controller: customerController,
                onTap: () {
                  showSearchPopup(context, 'Customer*');
                },
              ),
              TextField(
                decoration: InputDecoration(
                    labelText: 'Stylist*',
                ),
              ),
              GestureDetector(
              onTap: selectTime,
                child: AbsorbPointer(
                  child: TextField(decoration: InputDecoration(labelText: 'Time*') ,
                    controller: timeController,

                  ),
                ),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Treatment*'),
                onTap: () {
                  showSearchPopup(context, 'Treatment');
                },
              ),

              // Add more appointment fields as needed
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Perform necessary actions when the appointment is added
                // You can access the form values and process them here
                String time = timeController.text;
                String customer = customerController.text;
                bool isValid = true;
                List<String> errorFields = [];
                if(time.isEmpty || time == null){
                  isValid = false;
                  errorFields.add('Time');
                }

                if (!isValid) {
                  // Display error pop-up if any field is empty or null
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please fill in all required fields: ${errorFields.join(", ")}'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the error pop-up
                            },
                            child: Text('Ok'),
                          ),
                        ],
                      );
                    },
                  );
                }
                else{
                  Navigator.of(context).pop(); // Close the dialog
                }

              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // Set the background color to red
              ),
              child: Text('Create'),
            ),
            SizedBox(width: 30),
            ElevatedButton(
              onPressed: () {
                showConfirmation(context);
                //Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Set the background color to red
              ),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void showSearchPopup(BuildContext context, String field) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.30,
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Search $field',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter $field',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void showDatePickerDialog(BuildContext context) async{
    final DateTime ? pickedDate = await showDatePicker(
        context: context, initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100)
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void showConfirmation(BuildContext context){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text('Are you sure you want to cancel?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the confirmation dialog
                },
                child: Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the confirmation dialog
                  Navigator.of(context).pop(); // Close the appointment form dialog
                },
                child: Text('Yes'),
              ),
            ],
          );
        },
    );
  }
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, d MMMM yyyy').format(selectedDate);
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            color: Colors.white, // Set the background color of the container
          ),
          child: DropdownButton<String>(
            value: selectedValue,
            onChanged: (newValue) {
              setState(() {
                selectedValue = newValue!;
              });
            },
            items: <String>[
              'Hair And Beauty',
              'Spa'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(value),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(width: 30),
        IconButton(
            onPressed: selectBackDate,
            icon: Icon(Icons.arrow_back),
        ),
        SizedBox(width: 16),
        GestureDetector(
         onTap:() => showDatePickerDialog(context),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child:Text(
              formattedDate,
              style: TextStyle(fontSize: 16),
            )
          ),
        ),

        SizedBox(width: 16),
        IconButton(
          onPressed: selectNextDate,
          icon: Icon(Icons.arrow_forward),
        ),
        SizedBox(width: 30),
        ElevatedButton(
          onPressed: ()  => showAppointmentForm(context),
          child: Text('Add Appointment'),
        ),
      ],
    );
  }
}

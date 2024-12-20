import 'package:calendar_planner/config/global_config.dart' as config;
import 'package:calendar_planner/src/ProductDetails.dart';
import 'package:calendar_planner/src/calendar_planner_column.dart';
import 'package:calendar_planner/src/calendar_planner_filter.dart';
import 'package:calendar_planner/src/calendar_planner_style.dart';
import 'package:calendar_planner/src/calendar_planner_task.dart';
import 'package:calendar_planner/src/calendar_planner_time_task.dart';
import 'package:calendar_planner/src/calendar_planner_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:time_planner/time_planner.dart';
import 'package:calendar_planner/src/PersonDetails.dart';
import 'package:calendar_planner/src/BookingDetails.dart';
import 'package:mawa_package/mawa_package.dart';
import 'package:mawa_package/dependencies.dart';

import 'calendar_planner_employee_card.dart';
import 'calendar_planner_time.dart';

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

  /// Whether to display filter for the calendar
  final bool filter;
//
  final List<Map<String, String>> productList;
//
  List<MyTimePlannerTask> events;
//
  final List<String> people;
//
  void Function(String currentDate)? changeDate;
//
  void Function(BookingDetails booking)? submitBooking;
//
  void Function(Person person)? createPerson;
  //

  void Function(String productCode,int index)? productChange;
//
  final List<Person>? customer;
  //
  final List<ProductDetails>? products;
  //
  final List<Person>? stylist;
  //
  void Function(String category,String bookDate)? createBooking;

  final VoidCallback? onTap;
  //
  final int? productIndex;
  final String dateFormated;
  CalendarPlanner({
    Key? key,
    required this.startHour,
    required this.endHour,
    required this.headers,
    this.tasks,
    this.style,
    required this.productList,
    this.use24HourFormat = false,
    this.setTimeOnAxis = false,
    this.currentTimeAnimation,
    this.filter = false,
    this.changeDate,
    required this.people,
    this.productChange,
    this.submitBooking,
    required this.events,
    this.customer,
    this.products,
    this.stylist,
    this.createPerson,
    this.createBooking,
    this.onTap,
    this.productIndex,
    required this.dateFormated,
  }) : super(key: key);

  @override
  State<CalendarPlanner> createState() => _CalendarPlannerState();
}

class _CalendarPlannerState extends State<CalendarPlanner> {
  ScrollController mainHorizontalController = ScrollController();
  ScrollController mainVerticalController = ScrollController();
  ScrollController dayHorizontalController = ScrollController();
  ScrollController timeVerticalController = ScrollController();
  CalendarPlannerStyle style = CalendarPlannerStyle();
  List<CalendarPlannerTask> tasks = [];
  bool? isAnimated = true;

  DateTime selectedDate = DateTime.now();
  TextEditingController customerController = TextEditingController();
  TextEditingController customerIdController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController treatmentController = TextEditingController();
  TextEditingController stylistController = TextEditingController();
  TextEditingController bookDateController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();
  TextEditingController customerSurnameController = TextEditingController();
  TextEditingController customerEmailController = TextEditingController();
  TextEditingController customerContactNumber = TextEditingController();
  TextEditingController treatmentIdController = TextEditingController();
  TextEditingController stylistIdController = TextEditingController();


  TextEditingController bookTimeController = TextEditingController();

  TextEditingController timeEditController = TextEditingController();
  TextEditingController dateEditController = TextEditingController();

  late List<String> people = [];
  late String categorySelected;
  bool sought = false;
  late String status = '';
  late String? timeSelectedInList = '';
  late String dateSelected;
  List<String> hourIntervals = [];
  late List<Map<String, dynamic>> clients, productCategories, appointTasks;
  late List<Map<String, dynamic>> appointments = [];
  late List<MyTimePlannerTask> events = [];
  late List<Map<String, dynamic>> peopleResponsible = [];
  String formattedDateSelected = '';
  String? selectedTime = '';
  String? selectedTimeReschedule = '';
  late Booking booking;
  late final int avg_duration = 30;
  late List<Map<String, dynamic>> appointees;
  late Map<String, dynamic> client = {};
  late Map<String, dynamic> appointee = {};
  late Map<String, dynamic> appointTask = {};
  late Map<String, dynamic> appointment = {};
  final _formKey = GlobalKey<FormBuilderState>();


  /// check input value rules
  void _checkInputValue() {
    if (widget.startHour > widget.endHour) {
      throw FlutterError("Start hour should be lower than end hour");
    } else if (widget.startHour < 0) {
      throw FlutterError("Start hour should be larger than 0");
    } else if (widget.endHour > 24) {
      throw FlutterError("End hour should be lower than 24");
    } else if (widget.headers.isEmpty) {
      throw FlutterError("header can't be empty");
    }
  }

  /// create local style
  void _convertToLocalStyle() {
    style.backgroundColor = widget.style?.backgroundColor;
    style.cellHeight = widget.style?.cellHeight ?? 150;
    style.cellWidth = widget.style?.cellWidth ?? 90;
    style.horizontalTaskPadding = widget.style?.horizontalTaskPadding ?? 0;
    style.borderRadius = widget.style?.borderRadius ??
        const BorderRadius.all(Radius.circular(8.0));
    style.dividerColor = widget.style?.dividerColor;
    style.showScrollBar = widget.style?.showScrollBar ?? false;
    style.interstitialOddColor = widget.style?.interstitialOddColor;
    style.interstitialEvenColor = widget.style?.interstitialEvenColor;
  }

  //Function to initial calendar view
  void _initData() {
    _checkInputValue();
    _convertToLocalStyle();
    config.horizontalTaskPadding = style.horizontalTaskPadding;
    config.cellHeight = style.cellHeight;
    config.cellWidth = style.cellWidth;
    config.totalHours = (widget.endHour - widget.startHour).toDouble();
    config.totalDays = widget.headers.length;
    config.startHour = widget.startHour;
    config.use24HourFormat = widget.use24HourFormat;
    config.setTimeOnAxis = widget.setTimeOnAxis;
    config.borderRadius = style.borderRadius;
    isAnimated = widget.currentTimeAnimation;
    tasks = widget.tasks ?? [];
  }

  @override
  void initState() {
    _initData();
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      int hour = DateTime.now().hour;
      future();
      if (isAnimated != null && isAnimated == true) {
        if (hour > widget.startHour) {
          double scrollOffset =
              (hour - widget.startHour) * config.cellHeight!.toDouble();
          mainVerticalController.animateTo(
            scrollOffset,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCirc,
          );
          timeVerticalController.animateTo(
            scrollOffset,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCirc,
          );
        }
      }
    });
  }

  future() async {
    if (!sought) {

      productCategories = List<Map<String, dynamic>>.from(await FieldOptions()
          .getFieldOptions(FieldOptionTypes.fieldOptionCalendarProductCategory));
      DateTime today = DateTime.now();
      String todaysDate = DateFormat('yyyy-MM-dd').format(today);
      dateSelected = todaysDate;
      appointments = List<Map<String, dynamic>>.from(
          await Booking.search(bookDate: dateSelected));
      categorySelected = productCategories.first[JsonResponses.code];
      peopleResponsible = List<Map<String, dynamic>>.from(await Partners.search(
          attributeName: categorySelected, attributeValue: categorySelected));
      clients = List<Map<String, dynamic>>.from(await Partners.search(
        role: PartnerTypes.customer,
      ));
      generateHourIntervals();
      events = [];
      int index = 0;
      List<String> employees = [];

      for (var eventPeople in peopleResponsible) {
        String name =
            '${_initCap(eventPeople['name2'] ?? '')} ${_initCap(eventPeople['name1'] ?? '')}';
        for (var booking in appointments) {
          if (eventPeople['id'] == booking['employeeResponsible']?['id'] &&
              booking['status'] != "CANCELLED") {

            String bookTime = booking['bookTime'];
            List<String> timeParts = bookTime.split(':');
            int hours = int.parse(timeParts[0]);
            int minutes = int.parse(timeParts[1]);

            int duration =
                int.tryParse(booking['duration'] ?? '') ?? avg_duration;
            DateTime endTime = DateFormat('HH:mm')
                .parse(booking['bookTime'] ?? '')
                .add(Duration(minutes: duration));

            MyTimePlannerTask taskplanner = MyTimePlannerTask(
                color: Colors.white,
                dateTime: TimePlannerDateTime(day: index, hour: hours, minutes: minutes),
                minutesDuration: duration,
                daysDuration: 1,
                employeeName: name,
                child:  SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${booking['bookTime']} - ${DateFormat('HH:mm').format(endTime)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${booking['productDto']['description']}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${booking['customer']?[JsonResponses.name2] ?? ''} ${booking['customer']?[JsonResponses.name3] ?? ''} ${booking['customer']?[JsonResponses.name1] ?? ''}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  appointmentViewForm(booking['id']);
                });
            events.add(taskplanner);
            // print('This is the initial state with aprox all events $events');
          }
        }
        if (name != '') {
          employees.add(name);
        }
        index++;
      }
      people = employees;
      sought = true;
    }

    return sought;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Padding(
          // padding: EdgeInsets.only(
          //     //top: 16,
          //     left: 100,
          //     bottom: 32), // Adjust the top padding as needed
          Visibility(
            visible: widget.filter,
            child: CalendarPlannerFilter(
              products: widget.productList,
              changeDate: widget.changeDate,
              submit: widget.submitBooking,
              productChange: widget.productChange,
              customer: widget.customer,
              product: widget.products,
              stylists: widget.stylist,
              createPerson: widget.createPerson,
              createBooking: widget.createBooking,
              stylistLength: widget.people.length,
              selectedIndex: widget.productIndex,
              dateSelected: widget.dateFormated,

            ),
          ),
          Expanded(
            child:widget.people.length > 0
                ? CalendarPlannerTask(
                tasks: widget.events,
                employees: widget.people,
                startHour: widget.startHour,
                endHour: widget.endHour,
                onTap:  (){
                  appointmentForm(categorySelected,widget.dateFormated);
                })
                : Center(child:
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Icon(
                    Icons.error,
                    size:100,
                    color: Colors.black,
                  ),
                  Text('No data to display calendar. Please contact the system administrator.',
                    textAlign: TextAlign.center,)
                ]
            ),
            ),
          ),
        ],
      ),
    );
  }

  getAppointment(String id) async {
    booking = Booking(id);
    appointment = Map<String, dynamic>.from(await booking.searchById());
  }

  Future<void> appointmentForm(String category, String bookDate) async {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (
              context,
              setState,
              ) {
            return AlertDialog(
              actionsAlignment: MainAxisAlignment.start,
              title: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 27.0,
                    ),
                    child: Text(
                      ' Appointment Create',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: width * 0.75,
                height: height * 0.9,
                child: FutureBuilder(
                  future: futureAppointment(category),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    Widget widget;
                    if (snapshot.connectionState == ConnectionState.done) {
                      widget = createAppointmentForm(bookDate, category);
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      widget =
                          SnapShortStaticWidgets.snapshotWaitingIndicator();
                    } else if (snapshot.hasError) {
                      widget = Text('Error: ${snapshot.error}');
                    } else {
                      widget = Text('No data');
                    }
                    //widget = createAppointmentForm(bookDate);
                    return widget;
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
  createAppointmentForm(String selectedDate, String category) {
    generateHourIntervals();
    DateTime appointmentDate = DateTime.parse(selectedDate);
    bookDateController.text = selectedDate;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.fromLTRB(30, 5.0, 200.0, 5.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextFormField(
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  readOnly: true,
                  controller: TextEditingController(
                      text: DateFormat('EEEE, d MMMM yyyy')
                          .format(appointmentDate)),
                  decoration: Tools.textInputDecorations(
                    'Date',
                    Icons.calendar_today,
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                //Customer
                DropdownSearch<Map<String, dynamic>>(
                  selectedItem: client,
                  validator: (value) {
                    if (value == null || client.isEmpty) {
                      return 'Please Select Booking For';
                    }
                    return null;
                  },
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Booking For',
                      contentPadding: const EdgeInsets.fromLTRB(
                        2,
                        0,
                        0,
                        0,
                      ),
                      border: const OutlineInputBorder(),
                      prefixIcon: client.isEmpty
                          ? const Icon(Icons.person_off)
                          : const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person),
                      ),
                    ),
                  ),
                  dropdownBuilder:
                      (BuildContext context, Map<String, dynamic>? item) {
                    return Container(
                      padding: const EdgeInsets.all(
                        1.0,
                      ),
                      child: (item == null || client.isEmpty)
                          ? const ListTile(
                        contentPadding: EdgeInsets.only(
                          left: 7.0,
                        ),
                        title: Text(
                          'Select Booking For',
                        ),
                      )
                          : ListTile(
                        title: Text(
                          '${item[JsonResponses.title]?['description'] ?? ''} ${Strings.personNameFromJson(item)}',
                        ),
                        subtitle: Text(
                          '${item['identity']?['type']?['description'] ?? ''}\t${item['identity']?['number'] ?? ''}',
                        ),
                      ),
                    );
                  },
                  popupProps: PopupProps.dialog(
                    showSearchBox: true,
                    itemBuilder: (BuildContext context,
                        Map<String, dynamic> item, bool isSelected) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ),
                        decoration: !isSelected
                            ? null
                            : BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(
                            5.0,
                          ),
                          color: Colors.white,
                        ),
                        child: ListTile(
                          selected: isSelected,
                          title: Text(
                            '${item[JsonResponses.title]?['description'] ?? ''} ${Strings.personNameFromJson(item)}',
                          ),
                          subtitle: Text(
                            '${item['identity']?['type']?['description'] ?? ''}\t${item['identity']?['number'] ?? ''}',
                          ),
                          leading: const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                            ),
                          ),
                        ),
                      );
                    },
                    emptyBuilder: (context, string) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(
                            height: 10.0,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                'No Record Found',
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(
                              5.0,
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.plus_one,
                                  ),
                                  title: const Text(
                                    'Create Customer Full Details',
                                  ),
                                  subtitle: const Text(
                                    'Tap To Create',
                                  ),
                                  // onTap: fullPersonCreate,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                        ],
                      );
                    },
                    loadingBuilder: (context, string) {
                      return Center(
                        child: SnapShortStaticWidgets.snapshotWaitin(),
                      );
                    },
                    errorBuilder: (context, string, dynamic) {
                      return Center(
                        child: SnapShortStaticWidgets.snapshotError(),
                      );
                    },
                    searchFieldProps: const TextFieldProps(autofocus: true),
                  ),
                  asyncItems: (find) async {
                    List<Map<String, dynamic>> list = [];
                    if (find.isEmpty) {
                      list = clients;
                    } else {
                      for (int c = 0; c < clients.length; c++) {
                        if ('${clients[c][JsonResponses.title]?['description'] ?? '' ?? ''}${clients[c]['identity']?['type']?['description'] ?? ''}${clients[c]['identity']?['number'] ?? ''} ${Strings.personNameFromJson(clients[c])}'
                            .contains(find)) {
                          list.add(clients[c]);
                        }
                      }
                    }
                    return list;
                  },
                  onChanged: (data) {
                    setState(() {
                      client = Map<String, dynamic>.from(data!);
                    });
                  },
                ),
                const SizedBox(
                  height: 20.0,
                ),
                DropdownSearch<Map<String, dynamic>>(
                  selectedItem: appointee,
                  validator: (value) {
                    if (value == null || appointee.isEmpty) {
                      return 'Please Select Person Responsible';
                    }
                    return null;
                  },
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Person Responsible',
                      contentPadding: const EdgeInsets.fromLTRB(
                        2,
                        0,
                        0,
                        0,
                      ),
                      border: const OutlineInputBorder(),
                      prefixIcon: appointee.isEmpty
                          ? const Icon(Icons.person_off)
                          : const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person),
                      ),
                    ),
                  ),
                  dropdownBuilder:
                      (BuildContext context, Map<String, dynamic>? item) {
                    return Container(
                      padding: const EdgeInsets.all(
                        1.0,
                      ),
                      child: (item == null || appointee.isEmpty)
                          ? const ListTile(
                        contentPadding: EdgeInsets.only(
                          left: 7.0,
                        ),
                        title: Text(
                          'Select Person Responsible',
                        ),
                      )
                          : ListTile(
                        title: Text(
                          '${item[JsonResponses.title]?['description'] ?? ''} ${Strings.personNameFromJson(item)}',
                        ),
                      ),
                    );
                  },
                  popupProps: PopupProps.dialog(
                    showSearchBox: true,
                    itemBuilder: (BuildContext context,
                        Map<String, dynamic> item, bool isSelected) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ),
                        decoration: !isSelected
                            ? null
                            : BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(
                            5.0,
                          ),
                          color: Colors.white,
                        ),
                        child: ListTile(
                          selected: isSelected,
                          title: Text(
                            '${item[JsonResponses.title]?['description'] ?? ''} ${Strings.personNameFromJson(item)}',
                          ),
                          // subtitle: Text(
                          //   '${item['identity']?['type']?['description'] ?? ''}\t${item['identity']?['number'] ?? ''}',
                          // ),
                          leading: const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                            ),
                          ),
                        ),
                      );
                    },
                    emptyBuilder: (context, string) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(
                            height: 10.0,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                'No Record Found',
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    loadingBuilder: (context, string) {
                      return Center(
                        child: SnapShortStaticWidgets.snapshotWaitin(),
                      );
                    },
                    errorBuilder: (context, string, dynamic) {
                      return Center(
                        child: SnapShortStaticWidgets.snapshotError(),
                      );
                    },
                    searchFieldProps: const TextFieldProps(autofocus: true),
                  ),
                  asyncItems: (find) async {
                    List<Map<String, dynamic>> list = [];
                    if (find.isEmpty) {
                      list = appointees;
                    } else {
                      for (int c = 0; c < appointees.length; c++) {
                        if ('${appointees[c][JsonResponses.title]?['description'] ?? ''}${appointees[c]['identity']?['type']?['description'] ?? ''}${appointees[c]['identity']?['number'] ?? ''} ${Strings.personNameFromJson(appointees[c])}'
                            .contains(find)) {
                          list.add(appointees[c]);
                        }
                      }
                    }


                    return list;
                  },
                  onChanged: (data) {
                    setState(() {
                      appointee = Map<String, dynamic>.from(data!);
                    });
                  },
                ),
                const SizedBox(
                  height: 20.0,
                ),
                DropdownSearch<Map<String, dynamic>>(
                  validator: (value) {
                    if (value == null || appointTask.isEmpty) {
                      return 'Please Select Appointment';
                    }
                    return null;
                  },
                  selectedItem: appointTask,
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Appointment',
                      contentPadding: const EdgeInsets.fromLTRB(
                        2,
                        0,
                        0,
                        0,
                      ),
                      border: const OutlineInputBorder(),
                      prefixIcon: appointTask.isEmpty
                          ? const Icon(Icons.task)
                          : const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.task),
                      ),
                    ),
                  ),
                  dropdownBuilder: (
                      BuildContext context,
                      Map<String, dynamic>? item,
                      ) {
                    return Container(
                      padding: const EdgeInsets.all(
                        1.0,
                      ),
                      child: (item == null || appointTask.isEmpty)
                          ? const ListTile(
                        contentPadding: EdgeInsets.all(
                          1.0,
                        ),
                        title: Text(
                          'Select Appointment',
                        ),
                      )
                          : ListTile(
                        contentPadding: const EdgeInsets.all(
                          1.0,
                        ),
                        title: Text(
                          item[JsonResponses.description] ?? '',
                        ),
                        subtitle: Text(
                          'R${item['price-value'] ?? ''}',
                          textAlign: TextAlign.start,
                        ),
                      ),
                    );
                  },
                  popupProps: PopupProps.dialog(
                    showSearchBox: true,
                    itemBuilder: (
                        BuildContext context,
                        Map<String, dynamic> item,
                        bool isSelected,
                        ) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ),
                        decoration: !isSelected
                            ? null
                            : BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(
                            5.0,
                          ),
                          color: Colors.white,
                        ),
                        child: ListTile(
                          selected: isSelected,
                          title: Text(
                            item[JsonResponses.description] ?? '',
                          ),
                          subtitle: Text(
                            'R${item['price-value'] ?? ''}',
                          ),
                        ),
                      );
                    },
                    emptyBuilder: (context, string) {
                      return const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              'No Record Found',
                            ),
                          ],
                        ),
                      );
                    },
                    loadingBuilder: (context, string) {
                      return Center(
                        child: SnapShortStaticWidgets.snapshotWaitin(),
                      );
                    },
                    errorBuilder: (context, string, dynamic) {
                      return Center(
                        child: SnapShortStaticWidgets.snapshotError(),
                      );
                    },
                    searchFieldProps: const TextFieldProps(autofocus: true),
                  ),
                  asyncItems: (find) async {
                    List<Map<String, dynamic>> list = [];

                    if (find.isEmpty) {
                      list = appointTasks;
                    } else {
                      for (int c = 0; c < appointTasks.length; c++) {
                        if ('${appointTasks[c][JsonResponses.description] ?? ''} R${appointTasks[c]['price-value'] ?? ''}'
                            .contains(find)) {
                          list.add(appointTasks[c]);
                        }
                      }
                    }
                    return list;
                  },
                  onChanged: (data) {
                    appointTask = Map<String, dynamic>.from(data!);
                    if (appointTask['duration'] == null ||
                        appointTask['duration'] == " ") {
                      String info =
                          "Please note the selected appointment has no duration maintained. Appointment duration will be defaulted to $avg_duration minutes.";
                      informationDialog(context, info);
                    }
                  },
                ),
                const SizedBox(
                  height: 20.0,
                ),

                DropdownSearch<String>(
                    selectedItem: selectedTime,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please select the time of the Appointment.";
                      }
                      return null;
                    },
                    items: hourIntervals,
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Time slots',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                    ),
                    popupProps: const PopupProps.dialog(
                      showSearchBox: true,
                      showSelectedItems: true,
                    ),
                    onChanged: (val)  async {
                      setState(()  {
                        selectedTime = val;
                        timeSelectedInList = selectedTime;
                      });
                    }
                ),
                SizedBox(height: 15),

              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
                backgroundColor: Colors.green,
                hoverColor: Colors.green,
                onPressed: createBooking,
                icon: const Icon(
                  CupertinoIcons.check_mark,
                ),
                label: const Text('Create')),
            const SizedBox(width: 16.0),
            FloatingActionButton.extended(
                backgroundColor: Colors.red,
                onPressed: () =>
                    cancelCreation(context, 'Cancel Appointment Creation'),
                icon: const Icon(
                  CupertinoIcons.xmark,
                ),
                label: const Text('Cancel')),
          ],
        ),
      ),
    );
  }

  Future<void> appointmentViewForm(String id) async {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return await showDialog(
      // barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (
              context,
              setState,
              ) {
            return AlertDialog(
                actionsAlignment: MainAxisAlignment.start,
                title: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 27.0,
                      ),
                      child: Text(
                        ' Appointment View',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                content: SizedBox(
                    width: width * 0.75,
                    height: height * 0.9,
                    child: FutureBuilder(
                      future: getAppointment(id),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        Widget widget;
                        if (snapshot.connectionState == ConnectionState.done) {
                          // print(snapshot.hashCode);
                          // if(snapshot.data != null){
                          widget = viewAppointmentForm();
                          //}
                          // else{
                          //   widget = SnapShortStaticWidgets.futureNoData(
                          //     displayMessage: 'Appointment information could not be retrieved',
                          //   );
                          // }
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          widget = widget =
                              SnapShortStaticWidgets.snapshotWaitingIndicator();
                        } else if (snapshot.hasError) {
                          widget = Text('Error: ${snapshot.error}');
                        } else {
                          widget = Text('No data');
                        }
                        //widget = createAppointmentForm(bookDate);
                        return widget;
                      },
                    )));
          },
        );
      },
    );
  }

  viewAppointmentForm() {
    // DateTime appointmentDate = DateTime.parse(appointment['bookDate']);
    int duration = int.tryParse(appointment['duration'] ?? '') ?? avg_duration;
    DateTime endTime = DateFormat('HH:mm')
        .parse(appointment['bookTime'] ?? '')
        .add(Duration(minutes: duration));

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.fromLTRB(30, 5.0, 200.0, 5.0),
          child: FormBuilder(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                    readOnly: true,
                    controller: TextEditingController(
                        text: appointment[JsonResponses.number]),
                    decoration: Tools.textInputDecorations(
                      'Appointment No',
                      Icons.confirmation_num,
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                    readOnly: true,
                    controller: TextEditingController(
                        text: DateFormat('EEEE, d MMMM yyyy')
                            .format(DateTime.parse(appointment['bookDate']))),
                    decoration: Tools.textInputDecorations(
                      'Date',
                      Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                    readOnly: true,
                    controller: TextEditingController(
                        text:
                        '${appointment['bookTime']} - ${DateFormat('HH:mm').format(endTime)}'),
                    decoration: Tools.textInputDecorations(
                      'Time',
                      Icons.access_time,
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                    readOnly: true,
                    controller: TextEditingController(
                        text:
                        '${appointment['customer']?[JsonResponses.name2] ?? ''} ${appointment['customer']?[JsonResponses.name3] ?? ''} ${appointment['customer']?[JsonResponses.name1] ?? ''}'),
                    decoration: Tools.textInputDecorations(
                      'Booking For',
                      Icons.person,
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                    readOnly: true,
                    controller: TextEditingController(
                        text: appointment['productDto']['description']),
                    decoration: Tools.textInputDecorations(
                      'Appointment',
                      Icons.task,
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                    readOnly: true,
                    controller: TextEditingController(
                        text:
                        '${appointment['employeeResponsible']?[JsonResponses.name2] ?? ''} ${appointment['employeeResponsible']?[JsonResponses.name3] ?? ''} ${appointment['employeeResponsible']?[JsonResponses.name1] ?? ''}'),
                    decoration: Tools.textInputDecorations(
                      'Person Responsible',
                      Icons.person,
                    ),
                  ),
                ],
              )),
        ),
      ),
      floatingActionButton: Visibility(
        visible: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
                backgroundColor: Colors.green,
                hoverColor: Colors.green,
                onPressed: () => reschedule(context),
                icon: const Icon(
                  CupertinoIcons.check_mark,
                ),
                label: const Text('Reschedule Appointment')),
            const SizedBox(width: 16.0),
            FloatingActionButton.extended(
                backgroundColor: Colors.red,
                onPressed: () => cancelCreatedAppointment(
                    context, 'Cancel This Appointment'),
                icon: const Icon(
                  CupertinoIcons.xmark,
                ),
                label: const Text('Cancel Appointment')),
          ],
        ),
      ),
    );
  }

  generateHourIntervals() {
    hourIntervals = [];
    DateTime today = DateTime.now();
    String todaysDate = DateFormat('yyyy-MM-dd').format(today);
    DateTime now = new DateTime.now();
    DateTime min = new DateTime.now();// Get current date and time
    String currentHour = now.hour.toString();
    String hour = '';

    for (int i = 0; i < 24; i++) {
      hour = i.toString().padLeft(2, '0'); // Pad with leading zero

      if(int.parse(hour) >= 12){
        if(int.parse(hour) > int.parse(currentHour) && DateTime.parse(dateSelected).isAtSameMomentAs(DateTime.parse(todaysDate))){
          hourIntervals.add('$hour:00 pm');
          hourIntervals.add('$hour:30 pm');
        }else if(DateTime.parse(dateSelected).isAfter(DateTime.parse(todaysDate))){
          hourIntervals.add('$hour:00 pm');
          hourIntervals.add('$hour:30 pm');
        }
        else if(int.parse(hour) == int.parse(currentHour) && int.parse('$hour:30 pm'.substring(3,5)) > min.minute )
        {hourIntervals.add('$hour:30 pm');}
      }else{
        if(int.parse(hour) > int.parse(currentHour) && DateTime.parse(dateSelected).isAtSameMomentAs(DateTime.parse(todaysDate))) {
          hourIntervals.add('$hour:00 am');
          hourIntervals.add('$hour:30 am');
        }else if(DateTime.parse(dateSelected).isAfter(DateTime.parse(todaysDate))){
          hourIntervals.add('$hour:00 am');
          hourIntervals.add('$hour:30 am');
        }
        else if(int.parse(hour) == int.parse(currentHour) && min.minute < int.parse('$hour:30 am'.substring(3,5)))
        {hourIntervals.add('$hour:30 am');
        }
      }
    }
    // if(int.parse(hour) > 18){
    // hourIntervals.add('Available time will start tomorrow at 08:00 am');}
  }

  reschedule(BuildContext context) {
    generateHourIntervals();
    dateEditController.text = DateFormat('EEEE, d MMMM yyyy')
        .format(DateTime.parse(appointment['bookDate']));
    timeEditController.text = appointment['bookTime'];
    AwesomeDialog(
      context: context,
      width: 500.0,
      dialogType: DialogType.warning,
      title: 'Rescheduling Appointment',
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Center(
              child: Text('Rescheduling Appointment ',
                  style: TextStyle(
                    fontSize: 20.0, // Adjust the font size as needed
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
          const SizedBox(height: 10.0),
          TextFormField(
              textInputAction: TextInputAction.next,
              autofocus: true,
              readOnly: true,
              controller: dateEditController,
              decoration: Tools.textInputDecorations(
                'Date',
                Icons.calendar_today,
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  formattedDateSelected =
                      DateFormat('EEEE, d MMMM yyyy').format(pickedDate);
                  dateEditController.text = formattedDateSelected;
                  // Do something with the selected date
                }
              }),
          DropdownSearch<String>(
              selectedItem: selectedTimeReschedule,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please select the time of the Appointment.";
                }
                return null;
              },
              items: hourIntervals,
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: 'Time slots',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
              ),
              popupProps: const PopupProps.dialog(
                showSearchBox: true,
                showSelectedItems: true,
              ),
              onChanged: (val)  async {
                setState(()  {
                  if (selectedTimeReschedule == null ||
                      selectedTimeReschedule == ' ') {
                    String info =
                        "Please select the time of the Appointment.";
                    informationDialog(context, info);
                  }
                  else{
                    selectedTimeReschedule = val;
                    // timeSelectedInList = selectedTime;
                    timeEditController.text = selectedTimeReschedule.toString();
                  }
                });
              }
          ),
        ],
      ),

      btnCancel: TextButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        label: const Text(
          'Cancel',
        ),
        icon: const Icon(
          Icons.backspace_outlined,
        ),
        style: TextButton.styleFrom(
            foregroundColor: Colors.red.shade900,
            iconColor: Colors.red.shade900,
            backgroundColor: Colors.redAccent.shade100),
      ),
      btnOk: TextButton.icon(
        onPressed: () {
          editAppointment(context);
          Navigator.of(context).pop();
        },
        label: const Text(
          'Save',
        ),
        style: TextButton.styleFrom(
            foregroundColor: Colors.green.shade900,
            iconColor: Colors.green.shade900,
            backgroundColor: Colors.greenAccent.shade100),
        icon: const Icon(
          Icons.save_as,
        ),
      ),
    ).show();
  }

  void editAppointment(BuildContext context) async {
    String time = timeEditController.text;
    DateTime parsedDate = DateFormat('EEEE, d MMMM yyyy').parse(dateEditController.text);
    String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
    DateTime now = new DateTime.now();  // Get current date and time
    String currentHour = now.hour.toString();

    final OverlayWidgets overlay = OverlayWidgets(
      context: context,
    );

    booking = Booking(appointment['id']);

    if((int.parse(time.substring(0,2)) > int.parse(currentHour) || int.parse(time.substring(0,2)) < int.parse(currentHour)) &&
        (DateTime.parse(formattedDate).isAfter(DateTime.parse(appointment['bookDate'])) ||
            DateTime.parse(formattedDate).isAtSameMomentAs(DateTime.parse(appointment['bookDate'])))){
      status = 'Booked';
      await booking.edit(bookDate: formattedDate, bookTime: time, bookStatus: status);
      Alerts.toastMessage(
        message: 'Appointment rescheduled successfully',
        positive: true,
      );
      reloadData();
      overlay.dismissOverlay();
    }
  }

  void reloadData() async {
    final OverlayWidgets overlay = OverlayWidgets(
      context: context,
    );
    overlay.showOverlay(
      SnapShortStaticWidgets.snapshotWaitingIndicator(),
    );
    peopleResponsible = List<Map<String, dynamic>>.from(await Partners.search(
        attributeName: categorySelected, attributeValue: categorySelected));
    appointments = List<Map<String, dynamic>>.from(
        await Booking.search(bookDate: dateSelected));
    setState(() {
      client = {};
      appointee = {};
      appointTask = {};
      timeController = TextEditingController();
      List<String> employees = [];
      events = [];
      int indexTask = 0;
      for (var eventPeople in peopleResponsible) {
        String name =
            '${_initCap(eventPeople['name2'] ?? '')} ${_initCap(eventPeople['name1'] ?? '')}';
        for (var eventBooking in appointments) {
          if (eventPeople['id'] == eventBooking['employeeResponsible']?['id'] &&
              eventBooking['status'] != "CANCELLED") {
            String bookTime = eventBooking['bookTime'];
            List<String> timeParts = bookTime.split(':');
            int hours = int.parse(timeParts[0]);
            int minutes = int.parse(timeParts[1]);

            int duration =
                int.tryParse(eventBooking['duration'] ?? '') ?? avg_duration;
            DateTime endTime = DateFormat('HH:mm')
                .parse(eventBooking['bookTime'] ?? '')
                .add(Duration(minutes: duration));
            MyTimePlannerTask taskplanner = MyTimePlannerTask(
                color: Colors.white,
                dateTime: TimePlannerDateTime(
                    day: indexTask, hour: hours, minutes: minutes),
                minutesDuration: duration,
                daysDuration: 1,
                employeeName: name,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${eventBooking['bookTime']} - ${DateFormat('HH:mm').format(endTime)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${eventBooking['productDto']['description']}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${eventBooking['customer']?[JsonResponses.name2] ?? ''} ${eventBooking['customer']?[JsonResponses.name3] ?? ''} ${eventBooking['customer']?[JsonResponses.name1] ?? ''}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  appointmentViewForm(eventBooking['id']);
                });
            events.add(taskplanner);
          }
        }
        if (name != '') {
          employees.add(name);
        }
        indexTask++;
      }
      sought = true;
      people = employees;
      future();
      overlay.dismissOverlay();
    });
  }

  informationDialog(BuildContext context, String information) {
    AwesomeDialog(
        width: 800.0,
        context: context,
        title: 'Information',
        dialogType: DialogType.warning,
        body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Text(information),
            )),
        btnOk: TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          label: const Text(
            'Ok',
          ),
          icon: const Icon(
            CupertinoIcons.check_mark,
          ),
          style: TextButton.styleFrom(
              foregroundColor: Colors.blueAccent.shade200,
              iconColor: Colors.blueAccent.shade200,
              backgroundColor: Colors.blueAccent.shade100),
        )).show();
  }

  futureAppointment(String category) async {
    clients = List<Map<String, dynamic>>.from(
      await Partners.search(
        role: PartnerTypes.customer,
      ),
    );

    appointees = List<Map<String, dynamic>>.from(
      await Partners.search(
        attributeName: category,
        attributeValue: category,
      ),
    );
    appointTasks = List<Map<String, dynamic>>.from(
      await Product.search(
        type: category,
      ),
    );


    for (var tasks in appointTasks) {
      List<Map<String, dynamic>> prices = List<Map<String, dynamic>>.from(
        await Product(tasks['id']).getPrices(),
      );
      List<Map<String, dynamic>> attributes = List<Map<String, dynamic>>.from(
          await Product(tasks['id']).getAttributes());
      tasks['prices'] = prices;
      if (prices.length == 1) {
        tasks['price-value'] = prices[0]['value'];
      } else {
        for (var pricesTags in prices) {
          tasks['price-value'] = pricesTags['value'];
        }
      }
      for (var attr in attributes) {
        if (attr['attribute'] == 'DURATION') {
          tasks['duration'] = attr['value'];
        }
      }
    }
  }

  String _initCap(String value) {
    if (value.isEmpty) {
      return '';
    }
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  cancelCreatedAppointment(BuildContext context, String textDisplay) {
    AwesomeDialog(
      width: 500.0,
      context: context,
      title: 'Confirmation',
      dialogType: DialogType.question,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Text('Are You Sure You Want To $textDisplay?'),
        ),
      ),
      btnCancel: TextButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        label: const Text(
          'No',
        ),
        icon: const Icon(
          Icons.backspace_outlined,
        ),
        style: TextButton.styleFrom(
            foregroundColor: Colors.red.shade900,
            iconColor: Colors.red.shade900,
            backgroundColor: Colors.redAccent.shade100),
      ),
      btnOk: TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          cancelAppointment();
        },
        label: const Text(
          'Yes',
        ),
        style: TextButton.styleFrom(
            foregroundColor: Colors.green.shade900,
            iconColor: Colors.green.shade900,
            backgroundColor: Colors.greenAccent.shade100),
        icon: const Icon(
          Icons.save_as,
        ),
      ),
    ).show();
  }

  void cancelAppointment() async {
    final OverlayWidgets overlay = OverlayWidgets(
      context: context,
    );
    if (_formKey.currentState!.validate()) {
      overlay.showOverlay(
        SnapShortStaticWidgets.snapshotWaitingIndicator(),
      );
      booking = Booking(appointment['id']);
      dynamic delete = await booking.delete();

      if (delete.statusCode == 200 || delete.statusCode == 201) {
        Navigator.of(context).pop();
        Alerts.toastMessage(
          message: 'Appointment cancelled successfully',
          positive: true,
        );
      } else {
        Alerts.toastMessage(
          message: '${delete.statusCode ?? ''} Appointment cancellation failed',
          positive: false,
        );
      }
      reloadData();
      overlay.dismissOverlay();
    }
  }

  getAppointees(String category) async {
    appointees = List<Map<String, dynamic>>.from(
      await Partners.search(
        attributeName: category,
        attributeValue: category,
      ),
    );
  }

  void createBooking() async {
    final OverlayWidgets overlay = OverlayWidgets(
      context: context,
    );
    if (_formKey.currentState!.validate()) {
      overlay.showOverlay(
        SnapShortStaticWidgets.snapshotWaitingIndicator(),
      );
      dynamic create = await Booking.create(
          productId: appointTask[JsonResponses.id],
          customerId: client[JsonResponses.id],
          //employeeId: appointee[JsonResponses.id],
          employeeId: appointee[JsonResponses.id],
          bookDate: bookDateController.text,
          // bookTime: timeController.text
          bookTime: timeSelectedInList.toString()
      );

      if (create.statusCode == 200 || create.statusCode == 201) {
        Map<String, dynamic> appointment =
        Map<String, dynamic>.from(await NetworkRequests.decodeJson(
          create,
        ));
        //print(create);
        closeAppointmentForm();
        Alerts.toastMessage(
          message: 'Appointment created successfully',
          positive: true,
        );
      } else {
        Alerts.toastMessage(
          message: '${create.statusCode ?? ''} Appointment create failed',
          positive: false,
        );
      }
      // future();
      reloadData();
      overlay.dismissOverlay();
    }
  }

  cancelCreation(BuildContext context, String textDisplay) {
    AwesomeDialog(
      width: 500.0,
      context: context,
      title: 'Confirmation',
      dialogType: DialogType.question,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Text('Are You Sure You Want To $textDisplay?'),
        ),
      ),
      btnCancel: TextButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        label: const Text(
          'No',
        ),
        icon: const Icon(
          Icons.backspace_outlined,
        ),
        style: TextButton.styleFrom(
            foregroundColor: Colors.red.shade900,
            iconColor: Colors.red.shade900,
            backgroundColor: Colors.redAccent.shade100),
      ),
      btnOk: TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          closeCancelAppointmentForm();
        },
        label: const Text(
          'Yes',
        ),
        style: TextButton.styleFrom(
            foregroundColor: Colors.green.shade900,
            iconColor: Colors.green.shade900,
            backgroundColor: Colors.greenAccent.shade100),
        icon: const Icon(
          Icons.save_as,
        ),
      ),
    ).show();
  }

  void closeAppointmentForm() {
    Navigator.pop(context);
    reloadData();
  }

  void closeCancelAppointmentForm() {
    Navigator.pop(context);
    reloadData();
  }

  String formattedTime(int hour) {
    /// this method formats the input hour into a time string
    /// modifing it as necessary based on the use24HourFormat flag .
    if (config.use24HourFormat) {
      // we use the hour as-is
      return hour.toString() + ':00';
    } else {
      // we format the time to use the am/pm scheme
      if (hour == 0) return "12:00 am";
      if (hour < 12) return "$hour:00 am";
      if (hour == 12) return "12:00 pm";
      return "${hour - 12}:00 pm";
    }
  }
}

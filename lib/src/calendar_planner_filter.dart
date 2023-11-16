import 'dart:js_util';

import 'package:calendar_planner/src/BookingDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:calendar_planner/src/PersonDetails.dart';
import 'package:calendar_planner/src/ProductDetails.dart';

class CalendarPlannerFilter extends StatefulWidget {
  final List<Map<String, String>> products;
  final List<Person>? customer;
  final List<ProductDetails>? product;
  final List<Person>? stylists;
  final int? selectedIndex;
  void Function(String product)? productChange;
  //void Function()? customerSearch;
  //void Function()? employeeSearch;
  void Function(BookingDetails booking)? submit;
  void Function(Person partner)? createPerson;
  void Function(String currentDate)? changeDate;
  void Function(String category, String bookDate)? createBooking;


  CalendarPlannerFilter({
    Key? key,
    required this.products,
    this.productChange,
    //this.customerSearch,
    //this.employeeSearch,
    this.submit,
    this.changeDate,
    this.customer,
    this.product,
    this.stylists,
    this.createPerson,
    this.createBooking,
    this.selectedIndex,
  }) : super(key: key);

  @override
  _CalendarPlannerFilterState createState() => _CalendarPlannerFilterState();
}

class _CalendarPlannerFilterState extends State<CalendarPlannerFilter> {
  Map<String, String> selectedValue = {};
  List<Map<String, String>> productsList = [];

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

  @override
  void initState() {
    super.initState();
    productsList = widget.products;
    assert(widget.products.isNotEmpty, 'Products list must not be empty.');
    int index = widget.selectedIndex ?? 0;
    if (productsList.isNotEmpty) {
      selectedValue = productsList[index]; // Select the first item in the list
    }
  }

  void selectBackDate() {
    DateTime currentDate = DateTime.now();
    if (selectedDate.isAfter(currentDate)) {
      setState(() {
        selectedDate = selectedDate.subtract(Duration(days: 1));
      });
      if (widget.changeDate != null) {
        String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
        widget.changeDate!(formattedDate);
      }
    }
  }

  void selectNextDate() {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: 1));
    });
    if (widget.changeDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      widget.changeDate!(formattedDate);
    }
  }

  void showAppointmentForm(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        TimeOfDay? selectedTime;
        TextEditingController timeController = TextEditingController();
        Future<Null> selectTime() async {
          final TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: selectedTime ?? TimeOfDay.now(),
              builder: (BuildContext context, Widget? child) {
                return MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(alwaysUse24HourFormat: true),
                    child: child!);
              });
          if (pickedTime != null) {
            setState(() {
              String formattedTime = DateFormat.Hm().format(
                  DateTime(2023, 1, 1, pickedTime.hour, pickedTime.minute));
              timeController.text = formattedTime;
              // selectedTime =
              //     TimeOfDay(hour: pickedTime.hour, minute: pickedTime.minute);

              // timeController.text = selectedTime!.format(context);
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
                controller: TextEditingController(
                    text: DateFormat('EEEE, d MMMM yyyy').format(selectedDate)),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Customer*'),
                controller: customerController,
                onTap: () {
                  showCustomerSearchPopup(context);
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Stylist*'),
                controller: stylistController,
                onTap: () {
                  showStylistSearch(context);
                },
              ),
              GestureDetector(
                onTap: selectTime,
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Time*'),
                    controller: timeController,
                  ),
                ),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Treatment*'),
                controller: treatmentController,
                onTap: () {
                  showTreatSearchPopup(context);
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
                String customerId = customerIdController.text;
                String stylistId = stylistIdController.text;
                String productId = treatmentIdController.text;
                bool isValid = true;
                List<String> errorFields = [];

                if (time.isEmpty || time == null) {
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
                        content: Text(
                            'Please fill in all required fields: ${errorFields.join(", ")}'),
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
                } else {
                  //print(time);
                  //print(customerId);
                  BookingDetails booking = new BookingDetails();
                  String formattedDate =
                      DateFormat('yyyy-MM-dd').format(selectedDate);
                  booking.customerId = customerId;
                  booking.stylistId = stylistId;
                  booking.treatmentId = productId;
                  booking.bookDate = formattedDate;
                  booking.bookTime = time;
                  if (widget.submit != null) {
                    widget.submit!(booking);
                  }
                  Navigator.of(context).pop(); // Close the dialog
                  // if (widget.submit != null) {
                  //   widget.submit!();
                  // }
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

  // void showSearchPopup(BuildContext context, String field,bool searchType) {
  //
  //   List<String> searchOptions = ['Name','Surname','Cellphone','Email'];
  //   String selectedOption = "Name";
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(8.0),
  //         ),
  //         child: Container(
  //           width: MediaQuery.of(context).size.width * 0.30,
  //           padding: EdgeInsets.all(16.0),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Text(
  //                 'Search $field',
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               SizedBox(height: 16),
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: TextField(
  //                       decoration: InputDecoration(
  //                         hintText: 'Enter $field',
  //                         prefixIcon: Icon(Icons.search),
  //                         filled: true,
  //                         fillColor: Colors.grey[200],
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(8.0),
  //                           borderSide: BorderSide.none,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(width: 16),
  //                   InkWell(
  //                     onTap:(){},
  //                     child:Container(
  //                       padding: EdgeInsets.all(12),
  //                       decoration: BoxDecoration(
  //                         color: Colors.blue,
  //                         borderRadius: BorderRadius.circular(8.0)
  //                       ),
  //                       child:Icon(
  //                         Icons.search,
  //                         color: Colors.white,
  //                       )
  //                     )
  //                   )
  //                 ],
  //               ),
  //               SizedBox(height: 16),
  //               Row(
  //                 children: searchOptions.map((option){
  //                   return  Row(
  //                     children: [
  //                       Radio<String>(
  //                         value: option,
  //                         groupValue: selectedOption,
  //                         onChanged: (newValue){
  //                           setState(() {
  //                             selectedOption = newValue!;
  //                           });
  //                         },
  //                       ),
  //                       Text(option),
  //                     ],
  //                   );
  //                 }).toList(),
  //               ),
  //               SizedBox(height: 16),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // void search(BuildContext context){
  //
  // }

  void showDatePickerDialog(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
        widget.changeDate!(formattedDate);
      });
    }
  }

  void showCustomerCreate(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Customer Create'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name*'),
                controller: customerNameController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Surname*'),
                controller: customerSurnameController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Contact Number*'),
                controller: customerContactNumber,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Email Address'),
                controller: customerEmailController,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                String name = customerNameController.text;
                String surname = customerSurnameController.text;
                String contact = customerContactNumber.text;
                String email = customerEmailController.text;

                Person customerCreate = Person(
                    firstName: name,
                    surname: surname,
                    email: email,
                    contactNumber: contact);
                if (widget.createPerson != null) {
                  widget.createPerson!(customerCreate);
                }
                //print(customerCreate);
                //showConfirmation(context);
                Navigator.of(context).pop(); // Close the dialog
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

  void showStylistSearch(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    List<Person> filteredStylists = widget.stylists ?? [];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Stylist Search'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //    // Text('Stylist Search'),
                  //     GestureDetector(
                  //       onTap: () {
                  //         Navigator.pop(context);
                  //       },
                  //       child: Icon(Icons.close), // Close button (X)
                  //     ),
                  //   ],
                  // ),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(labelText: 'Search stylist'),
                    onChanged: (text) {
                      setState(() {
                        final String searchText = text.toLowerCase();
                        filteredStylists =
                            (widget.stylists ?? []).where((stylist) {
                          return (stylist.firstName?.toLowerCase() ?? '')
                                  .contains(searchText) ||
                              (stylist.middleName?.toLowerCase() ?? '')
                                  .contains(searchText) ||
                              (stylist.surname?.toLowerCase() ?? '')
                                  .contains(searchText);
                        }).toList();
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  if (filteredStylists.isNotEmpty)
                    Container(
                        width: 400,
                        child: SingleChildScrollView(
                          child: Column(
                            children: filteredStylists.map((stylist) {
                              return Card(
                                  elevation: 8,
                                  child: ListTile(
                                    leading: Icon(Icons.person_2_sharp),
                                    title: Text(
                                        '${stylist.firstName} ${stylist.middleName} ${stylist.surname}'),
                                    trailing: Icon(Icons.arrow_forward_ios),
                                    onTap: () {
                                      String name = stylist.firstName ?? '';
                                      String lastname = stylist.surname ?? '';
                                      stylistIdController.text =
                                          stylist.personId ?? '';
                                      stylistController.text =
                                          name + ' ' + lastname;
                                      Navigator.pop(context);
                                    },
                                  ));
                            }).toList(),
                          ),
                        ))
                  else
                    Text('No stylist match found')
                ],
              );
            },
          ),
          //barrierDismissible: false,
        );
      },
    );
  }

  void showTreatSearchPopup(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    List<ProductDetails> filteredProducts = widget.product ?? [];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Treatment Search'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(labelText: 'Search treatment'),
                    onChanged: (text) {
                      setState(() {
                        final searchString = text.toLowerCase();
                        filteredProducts =
                            (widget.product ?? []).where((product) {
                          return (product.code?.toLowerCase() ?? '')
                                  .contains(searchString) ||
                              (product.name?.toLowerCase() ?? '')
                                  .contains(searchString) ||
                              (product.price?.toLowerCase() ?? '')
                                  .contains(searchString);
                        }).toList();
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  if (filteredProducts.isNotEmpty)
                    Container(
                        width: 400,
                        child: SingleChildScrollView(
                          child: Column(
                            children: filteredProducts.map((product) {
                              return Card(
                                  elevation: 8,
                                  child: ListTile(
                                    //leading: Icon(Icons.i),
                                    title: Text('${product.name}'),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Price:R${product.price ?? '00.00'}'),
                                        Text('Code:${product.code ?? 'N/A'}'),
                                      ],
                                    ),
                                    trailing: Icon(Icons.arrow_forward_ios),
                                    onTap: () {
                                      String price = product.price ?? '00.00';
                                      String description = product.name ?? '';
                                      treatmentController.text = description;
                                      treatmentIdController.text =
                                          product.id ?? '';
                                      Navigator.pop(context);
                                    },
                                  ));
                            }).toList(),
                          ),
                        ))
                  else
                    Text('No matching treaments found.'),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void showCustomerSearchPopup(BuildContext context) {
    List<Person> filteredCustomers = widget.customer ?? [];
    //print(filteredCustomers.length);
    TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Customer Search'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(labelText: 'Search customer'),
                    onChanged: (text) {
                      //print("Search text: $text");
                      setState(() {
                        final String searchText = text.toLowerCase();
                        filteredCustomers =
                            (widget.customer ?? []).where((customer) {
                          return (customer.firstName?.toLowerCase() ?? '')
                                  .contains(searchText) ||
                              (customer.middleName?.toLowerCase() ?? '')
                                  .contains(searchText) ||
                              (customer.surname?.toLowerCase() ?? '')
                                  .contains(searchText) ||
                              (customer.contactNumber?.toLowerCase() ?? '')
                                  .contains(searchText) ||
                              (customer.email?.toLowerCase() ?? '')
                                  .contains(searchText);
                        }).toList();
                      });
                      // print("Filtered customers: ${filteredCustomers
                      //`   .length}");
                    },
                  ),
                  SizedBox(height: 10),
                  if (filteredCustomers.isNotEmpty)
                    Container(
                      width: 400,
                      child: SingleChildScrollView(
                        child: Column(
                          children: filteredCustomers.map((customer) {
                            return Card(
                              elevation: 8,
                              //margin: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                              child: ListTile(
                                leading: Icon(Icons.person),
                                title: Text(
                                    '${customer.firstName}  ${customer.middleName ?? ''} ${customer.surname ?? ''}'),
                                subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${customer.contactNumber ?? ''}'),
                                      Text('${customer.email ?? ''}'),
                                    ]),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Handle the selection of a customer here
                                  String surname = customer.surname ?? '';
                                  String name = customer.firstName ?? '';
                                  customerController.text =
                                      name + ' ' + surname;
                                  customerIdController.text =
                                      customer.personId ?? '';
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  else
                    Column(children: [
                      Text('No matching customers found.'),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          showCustomerCreate(context);
                          //showConfirmation(context);
                          //Navigator.of(context).pop(); // Close the dialog
                        },
                        style: ElevatedButton.styleFrom(
                          primary:
                              Colors.green, // Set the background color to red
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.person_add),
                            SizedBox(width: 8.0),
                            Text('Create new customer')
                          ],
                        ),
                      ),
                    ]),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void showConfirmation(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
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
                Navigator.of(context)
                    .pop(); // Close the appointment form dialog
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
    //assert(selectedValue != null, 'Selected value must not be null.');
    String formattedDate = DateFormat('EEEE, d MMMM yyyy').format(selectedDate);
    return Row(
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white, // Set the background color of the container
          ),
          child:
          DropdownButton<Map<String, String>>(
            value: selectedValue,
            onChanged: (newValue) {
              setState(() {
                selectedValue = newValue!;
                if (widget.productChange != null) {
                  widget.productChange!(selectedValue['code'] ?? '');
                }
              });
            },
            items:
                productsList.map<DropdownMenuItem<Map<String, String>>>((item) {
              final itemKey = Key(item['value'] ?? '');
              return DropdownMenuItem<Map<String, String>>(
                key: itemKey,
                value: item,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['value'] ?? ''),
                      // Text(
                      //   'Code: ${item['code'] ?? ''}',
                      //   style: TextStyle(fontSize: 12, color: Colors.grey),
                      // ),
                    ],
                  ),
                ),
              );
            }).toList(),
            underline: Container(),
            //items: <String>[
            //'Hair And Beauty',
            //'Spa'
            //].map<DropdownMenuItem<String>>((String value) {
            //return DropdownMenuItem<String>(
            // value: value,
            // child: Padding(
            // padding: const EdgeInsets.all(8.0),
            //  child: Text(value),
            //  ),
            //  );
            //  }).toList(),
          ),
        ),
        SizedBox(width: 30),
        IconButton(
          onPressed: selectBackDate,
          icon: Icon(Icons.arrow_back),
        ),
        SizedBox(width: 16),
        GestureDetector(
          onTap: () => showDatePickerDialog(context),
          child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                formattedDate,
                style: TextStyle(fontSize: 16),
              )),
        ),
        SizedBox(width: 16),
        IconButton(
          onPressed: selectNextDate,
          icon: Icon(Icons.arrow_forward),
        ),
        SizedBox(width: 30),
        ElevatedButton(
          onPressed: () {
            String selectedProduct = selectedValue['code'] ?? '';
            if(widget.createBooking != null){
              widget.createBooking!(selectedProduct, DateFormat('yyyy-MM-dd').format(selectedDate));
            }
            else{
              showAppointmentForm(context);
            }

          },
          child: Text('Add Appointment'),
        ),
      ],
    );
  }
}

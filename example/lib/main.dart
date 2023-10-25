import 'package:calendar_planner/calendar_planner.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void dateChange(String currentDate) {
    print("Change date is triggered");
    print(currentDate);
  }

  void submitBooking(Booking booking) {
    Map<String, dynamic> bookingJson = {
      "bookDate": booking.bookDate,
      "bookTime": booking.bookTime,
      "productId": booking.treatmentId,
      "employeeId": booking.stylistId,
      "customerId": booking.customerId
    };
    String bookingJsonString = json.encode(bookingJson);
    print("Submit triggered");
    print(bookingJsonString);
  }

  void createPartner(Person person) {
    Map<String, dynamic> partnerJson = {
      "partnerType": "INDIVISUAL",
      "surname": person.surname,
      "firstName": person.firstName,
      "middleName": person.middleName,
    };
    String partner = json.encode(partnerJson);
    print(partner);
    if(person.email != ''){
      Map<String, dynamic> emailJson = {
        "type": "EMAIL",
        "value": person.email
      };
      String email = json.encode(emailJson);
      print(email);
    }
    Map<String, dynamic> contactJson = {
      "type": "CELLPHONE",
      "value": person.contactNumber
    };
    String contact = json.encode(contactJson);
    print(contact);

  }
  void productChange(String product) {
    print("Product  change triggered");
    print(product);
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> product = [
      {
        'value': 'Product 1: Delivery To Warehouse And Delivery to customer',
        'code': '12345',
      },
      {
        'value': 'Product 2',
        'code': '67890',
      },
    ];
    List<String> employees = [
      "John",
      "Jane",
      "Alice",
      "Bob",
      "Eva",
      "Michael",
      "Olivia",
      "William",
      "Sophia",
      "David",
    ];
    List<MyTimePlannerTask> tasks = [
      MyTimePlannerTask(
        color: Colors.green,
        dateTime: TimePlannerDateTime(day: 0, hour: 13, minutes: 0),
        minutesDuration: 60,
        daysDuration: 1,
        employeeName: "John",
        onTap: () {},
        child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align text to the left
            children: [
              SizedBox(height: 10),
              Text(
                '13:00 - 13:30',
                style: TextStyle(
                  color: Colors.black, // The text color
                ),
                textAlign: TextAlign.left, // The text alignment
              ),
              SizedBox(height: 10),
              Text(
                'James Bond',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold, // The text color
                ),
                textAlign: TextAlign.left, // The text alignment
              ),
              SizedBox(height: 10),
              Text(
                'Hair And Beauty',
                style: TextStyle(
                  color: Colors.black, // The text color
                ),
                textAlign: TextAlign.left, // The text alignment
              ),
            ]), // child: Text(
        //  'Task 1',
        //   style: TextStyle(
        //       color: Colors.black
        //   ),
        //   textAlign: TextAlign.left,
        // ),
      ),
      MyTimePlannerTask(
        color: Colors.deepPurple,
        dateTime: TimePlannerDateTime(day: 1, hour: 14, minutes: 0),
        minutesDuration: 50,
        daysDuration: 1,
        employeeName: "Jane",
        onTap: () {},
        child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align text to the left
            children: [
              // SizedBox(height: 10),
              Text(
                '14:00 - 15:50',
                style: TextStyle(
                  color: Colors.black, // The text color
                ),
                textAlign: TextAlign.left, // The text alignment
              ),
              //    SizedBox(height: 10),
              Text(
                'James Bond',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold, // The text color
                ),
                textAlign: TextAlign.left, // The text alignment
              ),
              SizedBox(height: 10),
              Text(
                'Hair And Beauty',
                style: TextStyle(
                  color: Colors.black, // The text color
                ),
                textAlign: TextAlign.left, // The text alignment
              ),
            ]), // child: Text(
        //  'Task 1',
        //   style: TextStyle(
        //       color: Colors.black
        //   ),
        //   textAlign: TextAlign.left,
        // ),
      ),
    ];
    List<Person> partner = [
      Person(
        firstName: "James",
        middleName: "",
        surname: "Nkosi",
        contactNumber: "",
      ),
      Person(
        firstName: "John",
        middleName: "",
        surname: "Doe",
        contactNumber: "",
      ),
      Person(
          firstName: "Temba",
          middleName: "",
          surname: "Richie",
          contactNumber: "0814736003",
          email: "temba@gmail.com")
    ];
    List<Product> products = [
      Product(
        name: "Blow Dry",
        category: "",
        code: "",
        price: "300.00",
      ),
      Product(
        name: "Tai Massage",
        category: "",
        code: "",
        price: "600.00",
      ),
      Product(
        name: "Dyeing",
        category: "",
        code: "",
        price: "200.00",
      ),
      Product(
        name: "Fade Cut",
        category: "",
        code: "",
        price: "150.00",
      ),
      Product(
        name: "Pedicure",
        category: "",
        code: "",
        price: "200.00",
      ),
      Product(
        name: "Manicure",
        category: "",
        code: "",
        price: "150.00",
      ),
      Product(
        name: "Mani and Pedi",
        category: "",
        code: "",
        price: "300.00",
      )
    ];

    List<Person> stylist = [
      Person(
        firstName: "James",
        middleName: "Mikey",
        surname: "Nkosi",
        contactNumber: "",
      ),
      Person(
        firstName: "James",
        middleName: "Wesley",
        surname: "Nkosi",
        contactNumber: "",
      ),
      Person(
        firstName: "Joe",
        middleName: "",
        surname: "Doey",
        contactNumber: "",
      ),
      Person(
        firstName: "Justin",
        middleName: "",
        surname: "Bieber",
        contactNumber: "",
      ),
    ];
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body:
          //const Cale
          CalendarPlanner(
        startHour: 8,
        endHour: 17,
        headers: [
          CalendarPlannerTitle(
            title: 'Title',
          )
        ],
        filter: true,
        productList: product,
        people: employees,
        events: tasks,
        changeDate: dateChange,
        submitBooking: submitBooking,
        productChange: productChange,
        customer: partner,
        products: products,
        stylist: stylist,
        createPerson: createPartner,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

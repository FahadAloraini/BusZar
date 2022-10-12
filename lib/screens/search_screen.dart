import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:testing_phase1/components/rounded_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testing_phase1/components/PopUp.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchScreen extends StatefulWidget {
  static const String id = 'search_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  CollectionReference FTicket = FirebaseFirestore.instance.collection("Ticket");
  late AnimationController controller;
  late Animation animation;
  late String TypedSearch = "";
  late String IDNumber;
  late String IDData;
  var _controller = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User loggedInUser;
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print("loged in" + loggedInUser.email.toString());
        setState(() {});
      } else {
        print("hiooooooo");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // The search area here
          backgroundColor: Colors.deepPurple,
          title: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        TypedSearch = "";
                      },
                    ),
                    hintText: 'Search...',
                    border: InputBorder.none),
                onChanged: (value) {
                  setState(() {
                    TypedSearch = value;
                    print(TypedSearch);
                  });
                },
              ),
            ),
          )),
      body: StreamBuilder<QuerySnapshot>(
        stream: (TypedSearch != "" && TypedSearch != null)
            ? FirebaseFirestore.instance
                .collection('Ticket')
                .where("Destination", isEqualTo: TypedSearch)
                .snapshots()
            : FirebaseFirestore.instance.collection("Ticket").snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          return (snapshot.connectionState == ConnectionState.waiting)
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot data = snapshot.data!.docs[index];
                    return Container(
                      height: 130,
                      child: GestureDetector(
                        onTap: () {
                          Dialogs.bottomMaterialDialog(
                              customView: Card(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15)),
                                ),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 3),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Text(
                                        "Destination: " + data['Destination'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Boarding Location: " +
                                            data['Location'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Time: " + data['Time'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Price: " + data['Price'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 50,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              msg: data['Location'] +
                                  ' to ' +
                                  data['Destination'],
                              title: '',
                              context: context,
                              actions: [
                                IconsOutlineButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  text: 'Cancel',
                                  iconData: Icons.cancel_outlined,
                                  textStyle: TextStyle(color: Colors.grey),
                                  iconColor: Colors.grey,
                                ),
                                IconsButton(
                                  onPressed: () {
                                    // confirm
                                    FirebaseFirestore.instance
                                        .collection('History')
                                        .add({
                                      'Email': loggedInUser.email.toString(),
                                      'TicketNumber': data['Number'],
                                      'Destination': data['Destination'],
                                      'Location': data['Location'],
                                      'Price': data['Price'],
                                      'Time': data['Time'],
                                    });
                                    FirebaseFirestore.instance
                                        .collection('UserTicket')
                                        .add({
                                      'Email': loggedInUser.email.toString(),
                                      'TicketNumber': data['Number'],
                                      'Destination': data['Destination'],
                                      'Location': data['Location'],
                                      'Price': data['Price'],
                                      'Time': data['Time'],
                                    });
                                  },
                                  text: 'Confirm',
                                  iconData: Icons.add_location,
                                  color: Colors.deepPurpleAccent,
                                  textStyle: TextStyle(color: Colors.white),
                                  iconColor: Colors.white,
                                ),
                              ]);
                        },
                        child: Card(
                          shadowColor: Colors.black,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Destination: " +
                                      data['Destination'].toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  "Boarding Location: " +
                                      data['Location'].toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Time: " + data['Time'].toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 100,
                                    ),
                                    Text(
                                      "Price: " + data['Price'].toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}

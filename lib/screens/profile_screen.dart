import 'package:flutter/material.dart';
import 'package:testing_phase1/components/rounded_button.dart';
import 'package:testing_phase1/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testing_phase1/screens/home_screen.dart';
import 'package:testing_phase1/screens/welcome_screen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  static const String id = 'profile_screen';
  @override
  _ProfileScreen createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  void initState() {
    super.initState();
    getCurrentUser();
  }

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
  //var Fname = "Fahad";
  //var email = "";
  var phone = "0504400127";
  //var Lname = "Aloraini";

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Profile')
            .where("Email", isEqualTo: loggedInUser.email.toString())
            .snapshots(),
        builder: (context, snapshot) {
          return (snapshot.connectionState == ConnectionState.waiting)
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot data = snapshot.data!.docs[index];
                    return SafeArea(
                      minimum: EdgeInsets.only(top: 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            minRadius: 50,
                            maxRadius: 70,
                            child: Icon(
                              Icons.person,
                              size: 100,
                            ),
                            //backgroundImageIcon(Icons.person):,
                          ),
                          const SizedBox(
                            height: 20,
                            width: double.infinity,
                            child: Divider(
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            data['name'],
                            style: const TextStyle(
                              fontSize: 40.0,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Pacifico",
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                            width: double.infinity,
                            child: Divider(
                              color: Colors.black,
                            ),
                          ),
                          Card(
                            color: Colors.white,
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 25),
                            child: ListTile(
                              leading: const Icon(
                                Icons.email,
                                color: Colors.deepPurple,
                              ),
                              title: Text(
                                loggedInUser.email.toString(),
                                style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 20,
                                    fontFamily: "Source Sans Pro"),
                              ),
                            ),
                          ),
                          Card(
                            color: Colors.white,
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 25),
                            child: ListTile(
                              leading: Icon(
                                Icons.phone,
                                color: Colors.deepPurple,
                              ),
                              title: Text(
                                phone,
                                style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 20,
                                    fontFamily: "Source Sans Pro"),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                RoundedButton(
                                  title: 'Modify',
                                  colour: Colors.deepPurpleAccent,
                                  onPressed: () {},
                                ),
                                RoundedButton(
                                  title: 'Sign Out',
                                  colour: Colors.red,
                                  onPressed: () {
                                    _auth.signOut();
                                    Navigator.pushNamed(
                                        context, WelcomeScreen.id);
                                  },
                                ),
                              ],
                            ),
                          )

                          // we will be creating a new widget name info carrd
                        ],
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}

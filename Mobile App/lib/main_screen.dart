import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_automation/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

User loggedInUser;

class MainScreen extends StatefulWidget {
  static String id = 'main_screen';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final referenceDatabase = FirebaseDatabase.instance;
  final _auth = FirebaseAuth.instance;
  bool light = false;
  bool fan = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    try {
      if (user != null) {
        loggedInUser = user;
        print(user.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = referenceDatabase.reference();
    return Scaffold(
      appBar: AppBar(
        leading: Flexible(
          child: Hero(
            tag: 'logo',
            child: Container(
              height: 300.0,
              child: Image.asset('images/logo.png'),
            ),
          ),
        ),
        backgroundColor: Colors.black54,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.login_outlined),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('Remote Controller'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        light = light ? false : true;
                      });
                      ref.child('light').set(light).asStream();
                      ref.child('light').onChildChanged;
                    },
                    child: ReusableCard(
                        colour: light ? kActiveCardColour : kInactiveCardColour,
                        childCard: IconContent(
                          icon: Icons.lightbulb,
                          label: 'Light',
                          colour: light ? Colors.yellow : Colors.white,
                        )),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        fan = fan ? false : true;
                      });
                      ref.child('fan').set(fan).asStream();
                    },
                    child: ReusableCard(
                        colour: fan ? kActiveCardColour : kInactiveCardColour,
                        childCard: IconContent(
                          icon: FontAwesomeIcons.fan,
                          label: 'Fan',
                          colour: fan ? Colors.blue : Colors.white,
                        )),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ReusableCard(
                colour: kActiveCardColour,
                childCard:
                    TextContent(text: TempStream(), label: 'Temperature')),
          ),
          Expanded(
            child: ReusableCard(
                colour: kActiveCardColour,
                childCard:
                    TextContent(text: HumidityStream(), label: 'Humidity')),
          ),
        ],
      ),
    );
  }
}

class ReusableCard extends StatelessWidget {
  ReusableCard({@required this.colour, this.childCard});
  final Color colour;
  final Widget childCard;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: childCard,
      margin: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
          color: colour, borderRadius: BorderRadius.circular(10.0)),
    );
  }
}

class TextContent extends StatelessWidget {
  TextContent({this.text, this.label});
  final String label;
  final text;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        text,
        SizedBox(
          height: 15.0,
        ),
        Text(
          label,
          style: kLabelTextStyle,
        ),
      ],
    );
  }
}

class IconContent extends StatelessWidget {
  IconContent({this.icon, this.label, this.colour});
  final String label;
  final IconData icon;
  final Color colour;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 80.0,
          color: colour,
        ),
        SizedBox(
          height: 15.0,
        ),
        Text(
          label,
          style: kLabelTextStyle,
        ),
      ],
    );
  }
}

class TempStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          FirebaseDatabase.instance.reference().child('temperature').onValue,
      builder: (context, snap) {
        if (snap.hasError) return new Text('Error: ${snap.error}');
        if (snap.data == null)
          return new Center(
            child: new CircularProgressIndicator(),
          );
        final temp = snap.data.snapshot.value;
        return Text('$temp °C', style: kNumberTextStyle);
      },
    );
  }
}

class HumidityStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.reference().child('humidity').onValue,
      builder: (context, snap) {
        if (snap.hasError) return new Text('Error: ${snap.error}');
        if (snap.data == null)
          return new Center(
            child: new CircularProgressIndicator(),
          );
        print(snap.data.snapshot);
        final humid = snap.data.snapshot.value;
        return Text('$humid %', style: kNumberTextStyle);
      },
    );
  }
}

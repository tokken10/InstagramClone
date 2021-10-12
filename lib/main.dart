import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/pages/feed_page.dart';
import 'package:instagram/pages/home_page.dart';
import 'package:instagram/pages/login_page.dart';
import 'package:instagram/pages/signup_page.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserData(),
      child: MaterialApp(
        title: 'Instagram Clone',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryIconTheme:
              Theme.of(context).primaryIconTheme.copyWith(color: Colors.black),
        ),
        home: _getScreenId(),
        routes: {
          LoginPage.id: (context) => LoginPage(),
          SignupPage.id: (context) => SignupPage(),
          FeedPage.id: (context) => FeedPage()
        },
      ),
    );
  }

  Widget _getScreenId() {
    return StreamBuilder<FirebaseUser>(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            Provider.of<UserData>(context).currentUserId = snapshot.data.uid;
            return HomePage();
          } else {
            return LoginPage();
          }
        });
  }
}

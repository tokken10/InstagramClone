import 'package:flutter/material.dart';
import 'package:instagram/services/auth_services.dart';

class FeedPage extends StatefulWidget {
  FeedPage({Key key}) : super(key: key);
  static final String id = 'feed_screen';

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            'Instagram',
            style: TextStyle(
                color: Colors.black, fontFamily: 'Billabong', fontSize: 35),
          ),
        ),
      ),
      backgroundColor: Colors.deepOrange[200],
      body: Center(child: FlatButton(
        onPressed: () => AuthService.logOut(),
        child: Text('Log out'),
      ),),
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/pages/activity_page.dart';
import 'package:instagram/pages/create_post_page.dart';
import 'package:instagram/pages/feed_page.dart';
import 'package:instagram/pages/profile_page.dart';
import 'package:instagram/pages/search_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTab = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = Provider.of<UserData>(context).currentUserId;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          FeedPage(),
          SearchPage(),
          CreatePostPage(),
          ActivityPage(),
          ProfilePage(userId: currentUserId, currentUserId: currentUserId,)
        ],
        onPageChanged: (int index) {
          setState(() {
            _currentTab = index;
          });
        },
      ),
      bottomNavigationBar: CupertinoTabBar(
          backgroundColor: Colors.white,
          activeColor: Colors.black,
          currentIndex: _currentTab,
          onTap: (int index) {
            setState(() {
              _currentTab = index;
            });
            _pageController.animateToPage(index,
                duration: Duration(milliseconds: 200), curve: Curves.easeIn);
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 32,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                size: 32,
              ),
            ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.photo_camera,
                size: 32,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite_border,
                size: 32,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.account_circle,
                size: 32,
              ),
            )
          ]),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/pages/edit_profile_page.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/utils/constants.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  final String currentUserId;

  ProfilePage({Key key, this.userId, this.currentUserId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isFollowing = false;
  int followingCount = 0;
  int followersCount = 0;

  @override
  void initState() {
    super.initState();
    _setupIsFollowing();
    _setupFollowing();
    _setupFollowers();
  }

  _setupIsFollowing() async {
    bool isFollowingUser = await DatabaseService.isFollowingUser(
        currentUserId: widget.currentUserId, userId: widget.userId);
    setState(() {
      isFollowing = isFollowingUser;
    });
  }

  _setupFollowers() async {
    int userFollowerCount = await DatabaseService.numFollowers(widget.userId);
    setState(() {
      followersCount = userFollowerCount;
    });
  }

  _setupFollowing() async {
    int userFollowingCount = await DatabaseService.numFollowing(widget.userId);
    setState(() {
      followingCount = userFollowingCount;
    });
  }

  _followOrUnfollow() {
    if (isFollowing) {
  _unfollowUser();
    } else {
      _followUser();
    }
  }

  _unfollowUser() {
    DatabaseService.unfollowUser(currentUserId: widget.currentUserId, userId:widget.userId);
    setState(() {
      isFollowing = false;
      followersCount--;
    });
  }

  _followUser() {
    DatabaseService.followUser(currentUserId: widget.currentUserId, userId:widget.userId);
    setState(() {
      isFollowing = true;
      followersCount++;
    });
  }
 
  _displayButton(User user) {
    return user.id == Provider.of<UserData>(context).currentUserId
        ? Container(
            width: 190,
            child: FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text(
                'Edit profile',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditProfilePage(user: user))),
            ),
          )
        : Container(
            width: 190,
            child: FlatButton(
              color: isFollowing ? Colors.grey[200] : Colors.blue,
              textColor: isFollowing ? Colors.black : Colors.white,
              child: Text(
                isFollowing ? 'Unfollow' : 'Follow',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              onPressed: _followOrUnfollow,
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(left: 50.0),
          child: Center(
            child: Text(
              'Instagram',
              style: TextStyle(
                  color: Colors.black, fontFamily: 'Billabong', fontSize: 35),
            ),
          ),
        ),
        //centerTitle: true,
        actions: widget.currentUserId == widget.userId
            ? <Widget>[
                IconButton(
                  icon: Icon(Icons.brightness_low),
                  onPressed: () => ('configurations tap'),
                )
              ]
            : null,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
          future: usersRef.document(widget.userId).get(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            User user = User.fromDoc(snapshot.data);
            return ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 0),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 45.0,
                        backgroundColor: Colors.grey,
                        backgroundImage: user.profileImageURL.isEmpty
                            ? AssetImage('assets/images/user_placeholder.png')
                            : CachedNetworkImageProvider(user.profileImageURL),
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text('12',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600)),
                                    Text('posts',
                                        style:
                                            TextStyle(color: Colors.black54)),
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(followersCount.toString(),
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600)),
                                    Text('followers',
                                        style:
                                            TextStyle(color: Colors.black54)),
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(followingCount.toString(),
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600)),
                                    Text('following',
                                        style:
                                            TextStyle(color: Colors.black54)),
                                  ],
                                )
                              ],
                            ),
                            _displayButton(user)
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        user.name,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 80,
                        child: Text(
                          user.bio,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      Divider()
                    ],
                  ),
                )
              ],
            );
          }),
    );
  }
}

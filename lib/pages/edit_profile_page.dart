import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/services/storage_service.dart';
import 'package:instagram/utils/media_helper.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  EditProfilePage({Key key, this.user}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String _name, _bio;
  File _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.user.name;
    _bio = widget.user.bio;
  }

  _handleImageFromGallery() async {
    File imageFile = await MediaHelper.handleImageFromGallery();
    if (imageFile != null) {
      setState(() {
        _profileImage = imageFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Edit Profile', style: TextStyle(color: Colors.black)),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          children: <Widget>[
            _isLoading
                ? LinearProgressIndicator(
                    backgroundColor: Colors.blue[200],
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                  )
                : SizedBox.shrink(),
            Padding(
              padding: EdgeInsets.all(25.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey,
                      backgroundImage: _displayProfilePhoto(),
                    ),
                    FlatButton(
                      onPressed: () => _handleImageFromGallery(),
                      child: Text('Change profile image',
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 14)),
                    ),
                    TextFormField(
                      initialValue: _name,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                          icon: Icon(
                            Icons.person,
                            size: 30,
                          ),
                          labelText: 'Name'),
                      validator: (input) => input.trim().length < 1
                          ? 'Please enter a valid name'
                          : null,
                      onSaved: (input) => _name = input,
                    ),
                    TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      initialValue: _bio,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                          icon: Icon(
                            Icons.book,
                            size: 30,
                          ),
                          labelText: 'Bio'),
                      validator: (input) => input.trim().length > 150
                          ? 'Please enter a bio less than 150 characters'
                          : null,
                      onSaved: (input) => _bio = input,
                    ),
                    Container(
                      margin: EdgeInsets.all(40.0),
                      height: 40,
                      width: 250,
                      child: FlatButton(
                        onPressed: _submit,
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: Text(
                          'Save profile',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState.validate() && !_isLoading) {
      _formKey.currentState.save();
      setState(() {
        _isLoading = true;
      });

      String _profileImageURL = '';

      if (_profileImage == null) {
        _profileImageURL = widget.user.profileImageURL;
      } else {
        _profileImageURL = await StorageService.uploadUserProfileImage(
            widget.user.profileImageURL, _profileImage);
      }

      // updating user in database
      User user = User(
          id: widget.user.id,
          name: _name,
          bio: _bio,
          profileImageURL: _profileImageURL);
      // db update
      DatabaseService.updateUser(user);

      Navigator.pop(context);
    }
  }

  _displayProfilePhoto() {
    // no new profile image
    if (_profileImage == null) {
      if (widget.user.profileImageURL.isEmpty) {
        // display placeholder
        return AssetImage('assets/images/user_placeholder.png');
      } else {
        // user profile image exists
        return CachedNetworkImageProvider(widget.user.profileImageURL);
      }
    } else {
      return FileImage(_profileImage);
    }
  }
}

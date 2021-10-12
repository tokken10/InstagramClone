import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/services/storage_service.dart';
import 'package:instagram/utils/media_helper.dart';
import 'package:provider/provider.dart';

class CreatePostPage extends StatefulWidget {
  CreatePostPage({Key key}) : super(key: key);

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  File _imageFile;
  var _captionController = TextEditingController();
  String _caption = '';
  bool _isLoading = false;

  _handleImage(ImageSource source) async {
    Navigator.pop(context);
    File imgFile = await ImagePicker.pickImage(source: source);
    if (imgFile != null) {
      imgFile = await MediaHelper.cropImage(imgFile);
      setState(() {
        _imageFile = imgFile;
      });
    }
  }

  // _cropImage(File imageFile) async {
  //   File cropped = await ImageCropper.cropImage(
  //       sourcePath: imageFile.path,
  //       aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0));
  //   return cropped;
  // }

  _showSelectImageDialog() {
    return Platform.isIOS ? _iosBottomSheet() : _androidDialog();
  }

  _iosBottomSheet() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text('Add photo'),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text('Take a photo'),
                onPressed: () => _handleImage(ImageSource.camera),
              ),
              CupertinoActionSheetAction(
                child: Text('Choose from gallery'),
                onPressed: () => _handleImage(ImageSource.gallery),
              )
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
          );
        });
  }

  _androidDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Add photo'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Take photo'),
                onPressed: () => _handleImage(ImageSource.camera),
              ),
              SimpleDialogOption(
                child: Text('Choose from gallery'),
                onPressed: () => _handleImage(ImageSource.gallery),
              ),
              SimpleDialogOption(
                child:
                    Text('Cancel', style: TextStyle(color: Colors.redAccent)),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  _submit() async {
    if (!_isLoading && _imageFile != null) {
      setState(() {
        _isLoading = true;
      });
    }

    // create post
    var imageUrl = await StorageService.uploadPost(_imageFile);
    var post = Post(
        imageUrl: imageUrl,
        caption: _caption,
        likes: {},
        authorId: Provider.of<UserData>(context).currentUserId,
        timestamp: Timestamp.fromDate(DateTime.now()));
    DatabaseService.createPost(post);

    // reset data
    _captionController.clear();
    setState(() {
      _caption = '';
      _imageFile = null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Center(
            child: Padding(
              padding: EdgeInsets.only(left: 50),
              child: Text(
                'Create post',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _submit,
            )
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Container(
              height: height,
              child: Column(
                children: <Widget>[
                  _isLoading
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.blue[200],
                            valueColor: AlwaysStoppedAnimation(Colors.blue),
                          ),
                        )
                      : SizedBox.shrink(),
                  GestureDetector(
                    onTap: _showSelectImageDialog,
                    child: Container(
                      height: width,
                      width: width,
                      color: Colors.grey[300],
                      child: _imageFile == null
                          ? Icon(Icons.add_a_photo,
                              color: Colors.white, size: 150)
                          : Image(
                              image: FileImage(_imageFile),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.0),
                    child: TextField(
                      controller: _captionController,
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        labelText: 'Caption',
                      ),
                      onChanged: (input) => _caption = input,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class MediaHelper {
  static handleImageFromGallery() async {
    return await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  static handleImageFromCamera() async {
    return await ImagePicker.pickImage(source: ImageSource.camera);
  }

  static handleImage(ImageSource source) async {
    return await ImagePicker.pickImage(source: source);
  }

  static getUserProgileImage(String url) {
    return url.isEmpty
        ? AssetImage('assets/images/user_placeholder.png')
        : CachedNetworkImageProvider(url);
  }

  static cropImage(File imageFile) async {
    File cropped = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0));
    return cropped;
  }
}

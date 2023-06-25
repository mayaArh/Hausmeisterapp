import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mein_digitaler_hausmeister/model_classes.dart/staff.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/firestore_data_provider.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class UserImage extends StatefulWidget {
  final Function(String imageUrl) onFileChanged;

  const UserImage({super.key, required this.onFileChanged});

  @override
  State<UserImage> createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  final FirestoreDataProvider _dataProvider = FirestoreDataProvider();
  final ImagePicker _picker = ImagePicker();
  final ImageCropper _imageCropper = ImageCropper();
  final storageRef = FirebaseStorage.instance.ref();
  static const janitorPath = 'janitorImages';
  static const buildingManagementPath = 'propertyManagementImages';

  String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (imageUrl == null)
          Icon(
            Icons.image,
            size: 50,
            color: Theme.of(context).primaryColor,
          )
        else
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () => _selectPhoto(),
            child: Image(
              image: NetworkImage(imageUrl!),
              width: 300,
              height: 300,
            ),
          ),
        InkWell(
            onTap: () => _selectPhoto(),
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  imageUrl == null ? 'Foto auswählen' : 'Foto ändern',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                )))
      ],
    );
  }

  Future _selectPhoto() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => BottomSheet(
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.filter),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            )
          ],
        ),
        onClosing: () {},
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile =
        await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile == null) {
      return;
    }
    final croppedFile = await _imageCropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1.3, ratioY: 1));
    if (croppedFile == null) {
      return;
    }
    XFile file = await _compressImage(croppedFile.path, 35);

    await _uploadFile(file.path);
  }

  Future<XFile> _compressImage(String path, int quality) async {
    final newPath = p.join((await getTemporaryDirectory()).path,
        '${DateTime.now()}.${p.extension(path)}');
    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      newPath,
      quality: quality,
    );

    return result!;
  }

  Future _uploadFile(String path) async {
    String userPath = '';
    if (_dataProvider.staffUser is Janitor) {
      userPath = janitorPath;
    }
    if (_dataProvider.staffUser is BuildingManagement) {
      userPath = buildingManagementPath;
    }
    final ref = storageRef
        .child(userPath)
        .child(DateTime.now().toIso8601String() + p.basename(path));
    final result = await ref.putFile(File(path));
    final fileUrl = await result.ref.getDownloadURL();

    setState(() {
      imageUrl = fileUrl;
    });

    widget.onFileChanged(fileUrl);
  }
}

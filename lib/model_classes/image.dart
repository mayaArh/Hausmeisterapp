import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mein_digitaler_hausmeister/constants/layout_sizes.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// Widget for displaying an user image and storing it in Firebase Storage.
// If `canBeEdited` is true, the user can add a new image, change
// the existing image, or delete the existing image.
class UserImage extends StatefulWidget {
  final String? initialImageUrl;
  final bool canBeEdited;
  final Function(String? imageUrl) onFileChanged;

  const UserImage({
    Key? key,
    required this.initialImageUrl,
    required this.canBeEdited,
    required this.onFileChanged,
  }) : super(key: key);

  @override
  State<UserImage> createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  final ImagePicker _picker = ImagePicker();
  final ImageCropper _imageCropper = ImageCropper();
  final storageRef = FirebaseStorage.instance.ref();
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    imageUrl = widget.initialImageUrl;
  }

  @override
  void didUpdateWidget(covariant UserImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImageUrl != oldWidget.initialImageUrl) {
      setState(() {
        imageUrl = widget.initialImageUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.canBeEdited ||
            (!widget.canBeEdited && widget.initialImageUrl != null)
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    if (widget.canBeEdited) {
                      _selectImage();
                    }
                  },
                  child: Container(
                    width: imageWidth,
                    height: imageHeight,
                    padding: const EdgeInsets.all(8),
                    child: widget.canBeEdited || imageUrl != null
                        ? Stack(
                            children: [
                              _showImageContainer(imageUrl, context),
                              widget.canBeEdited
                                  ? Positioned(
                                      width: 50,
                                      height: 50,
                                      top: 0,
                                      right: 0,
                                      child: _showDeleteButton())
                                  : Container()
                            ],
                          )
                        : Container(),
                  ),
                ),
              ),
            ],
          )
        : const SizedBox(height: 30);
  }

  Future<void> _selectImage() async {
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
            ),
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
      aspectRatio: const CropAspectRatio(ratioX: 1.5, ratioY: 1),
    );
    if (croppedFile == null) {
      return;
    }
    final file = await _compressImage(croppedFile.path, 35);
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

  Future<void> _uploadFile(String path) async {
    final ref = storageRef
        .child(AuthService.firebase().currentUser!.uid + p.basename(path));
    final result = await ref.putFile(File(path));
    final fileUrl = await result.ref.getDownloadURL();
    setState(() {
      imageUrl = fileUrl;
    });
    widget.onFileChanged(fileUrl);
  }

  GestureDetector _showImageContainer(String? imageUrl, BuildContext context) {
    return GestureDetector(
      onTap: () => widget.canBeEdited ? _selectImage() : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: imageWidth,
                    height: imageHeight,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!,
                          ),
                        );
                      }
                    },
                  )
                : widget.canBeEdited
                    ? Center(
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          size: 50,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : null,
          ),
          if (widget.canBeEdited)
            Positioned(
              width: 200,
              height: 200,
              child: GestureDetector(
                onTap: () => _selectImage(),
                behavior: HitTestBehavior.translucent,
              ),
            ),
        ],
      ),
    );
  }

  GestureDetector _showDeleteButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          imageUrl = null;
        });
        widget.onFileChanged(null);
        _showImageContainer(imageUrl, context);
      },
      child: imageUrl != null && imageUrl != ''
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(3.0),
              ),
              padding: const EdgeInsets.all(3.0),
              child: const Icon(
                Icons.delete_outline_outlined,
                size: 26,
              ))
          : null,
    );
  }
}

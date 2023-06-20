import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImage extends StatefulWidget {
  final Function(String imageUrl) onFileChanged;

  const UserImage({super.key, required this.onFileChanged});

  @override
  State<UserImage> createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  final ImagePicker _picker = ImagePicker();

  String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (imageUrl == null)
          Icon(
            Icons.image,
            size: 60,
            color: Theme.of(context).primaryColor,
          )
        else
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () => _selectPhoto(),
            child: Image(image: NetworkImage(imageUrl!)),
          ),
        InkWell(
            onTap: () => _selectPhoto(),
            child: Padding(
                padding: const EdgeInsets.all(8.0),
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
                      leading: Icon(Icons.camera),
                      title: Text('Kamera'),
                      onTap: () {
                        Navigator.of(context).pop();
                        _pickImage(ImageSource.camera);
                      },
                    )
                  ],
                )));
  }
}

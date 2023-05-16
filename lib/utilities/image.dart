class Image {
  final int _id;
  String _image;

  Image(this._id, this._image);

  factory Image.fromMapObject(Map<String, dynamic> map) =>
      Image(map['id'], map['image']);

  int get id {
    return _id;
  }

  String get image {
    return _image;
  }

  set image(String newImage) {
    _image = newImage;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = _id;
    map['image'] = _image;
    return map;
  }
}

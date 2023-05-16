import 'package:cloud_firestore/cloud_firestore.dart';

typedef RestaurantPressedCallback = void Function(ProjectModel projectModel);
typedef CloseProjectModelPressedCallback = void Function();

class ProjectModel {
  String? id;
  String? projectName;

  static final columns = ["id", "projectName"];

  ProjectModel({this.id, this.projectName});

  /*ProjectModel.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;
    projectName = snapshot.value!.toString();
  }*/

  factory ProjectModel.fromSnapshot(DocumentSnapshot snapshot) {
    final _snapshot = snapshot.data() as Map<String, dynamic>;
    return ProjectModel(
        id: snapshot["id"], projectName: _snapshot["projectName"]);
  }

  String projectNameAsString() {
    return '#${this.id} ${this.projectName}';
  }

  String? get setprojectname => projectName!;

  toJson() {
    return {"id": id, "projectName": projectName};
  }

  ///this method will prevent the override of toString
  bool? projectFilterByName(String filter) {
    return this.projectName.toString().contains(filter);
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(ProjectModel model) {
    return this.id == model.id;
  }

  @override
  String toString() => projectName!;
}

class Character {
  int id;
  String name;
  String img;
  String nickname;

  Character.fromJson(Map json)
      : id = json['id'],
        name = json['name'],
        img = json['img'],
        nickname = json['nickname'];

  Map toJson() {
    return {'id': id, 'name': name, 'img': img, 'nickname': nickname};
  }
}

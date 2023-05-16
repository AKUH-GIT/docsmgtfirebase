import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docsmgtfirebase/ui/Model/ProjectModel.dart';

abstract class ProjectProvider {
  Stream<List<ProjectModel>> get allRestaurants;

  Future<void> addProjects(ProjectModel projectModel);

  void addProjectsBatch(List<ProjectModel> projectModel);

  void loadAllProjects();

  void loadFilteredProjects(Filter filter);

  Future<ProjectModel> getProjectsById(String projectID);

  void dispose();
}

class FirestoreProjectProvider implements ProjectProvider {
  FirestoreProjectProvider() {
    allRestaurants = _allRestaurantsController.stream;
  }

  final StreamController<List<ProjectModel>> _allRestaurantsController =
      StreamController();

  @override
  late final Stream<List<ProjectModel>> allRestaurants;

  @override
  Future<void> addProjects(ProjectModel projectModel) {
    final projectModels = FirebaseFirestore.instance.collection('ProjectEntry');

    return projectModels
        .add({'id': projectModel.id, 'projectName': projectModel.projectName});
  }

  @override
  void addProjectsBatch(List<ProjectModel> projectModel) =>
      projectModel.forEach(addProjects);

  @override
  void loadAllProjects() {
    final _querySnapshot = FirebaseFirestore.instance
        .collection('ProjectEntry')
        .orderBy('id', descending: true)
        .limit(50)
        .snapshots();

    _querySnapshot.listen((event) {
      final _restaurants = event.docs.map((DocumentSnapshot doc) {
        return ProjectModel.fromSnapshot(doc);
      }).toList();

      _allRestaurantsController.add(_restaurants);
    });
  }

  @override
  void loadFilteredProjects(Filter filter) {
    Query collection = FirebaseFirestore.instance.collection('ProjectEntry');

    /*if (filter.category != null) {
      collection = collection.where('category', isEqualTo: filter.category);
    }
    if (filter.city != null) {
      collection = collection.where('city', isEqualTo: filter.city);
    }
    if (filter.price != null) {
      collection = collection.where('price', isEqualTo: filter.price);
    }*/

    final _querySnapshot = collection.limit(50).snapshots();

    _querySnapshot.listen((event) {
      final _restaurants = event.docs.map((DocumentSnapshot doc) {
        return ProjectModel.fromSnapshot(doc);
      }).toList();

      _allRestaurantsController.add(_restaurants);
    });
  }

  void dispose() {
    _allRestaurantsController.close();
  }

  @override
  Future<ProjectModel> getProjectsById(String restaurantId) {
    return FirebaseFirestore.instance
        .collection('ProjectEntry')
        .doc(restaurantId)
        .get()
        .then((DocumentSnapshot doc) => ProjectModel.fromSnapshot(doc));
  }
}

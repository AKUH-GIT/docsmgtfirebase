import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docsmgtfirebase/ui/Model/ProjectModel.dart';
import 'package:docsmgtfirebase/ui/SampleEntry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/Utils.dart';
import '../widgets/RoundButton.dart';

class ProjectEntry extends StatefulWidget {
  const ProjectEntry({Key? key}) : super(key: key);

  @override
  State<ProjectEntry> createState() => ProjectEntryState();
}

class ProjectEntryState extends State<ProjectEntry> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  int next_project_Id = 0;

  final CollectionReference<Map<String, dynamic>> projectLst =
      FirebaseFirestore.instance.collection('projectEntry');

  TextEditingController controller_projectName = new TextEditingController();

  late List<ProjectModel> lst_project = [];

  var focusNode = FocusNode();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  void _clearField() {
    _formKey.currentState!.reset();
    controller_projectName.text = "";
  }

  showAlertDialog(BuildContext context, String msg) {
    // set up the buttons
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        _clearField();
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alert Dialog"),
      content: Text(msg),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  getProjectID() async {
    var collection = FirebaseFirestore.instance.collection('ProjectEntry');

    var querySnapshot = await collection.get();
    for (var queryDocumentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data = queryDocumentSnapshot.data();
      var id = data['id'];
      var projectName = data['projectName'];
    }
    next_project_Id = querySnapshot.size + 1;
  }

  Future<bool> IsProjectExists(String projectName) async {
    var collection = FirebaseFirestore.instance.collection('ProjectEntry');
    var querySnapshot = await collection.get();
    for (var queryDocumentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data = queryDocumentSnapshot.data();
      if (projectName == data['projectName']) {
        Utils().toastMessage('Project already exists');
        setState(() {
          loading = false;
        });
        return true;
      }
    }
    return false;
  }

  Future<int> getProjectID_old() async {
    AggregateQuerySnapshot query = await projectLst.count().get();
    debugPrint('The number of products: ${query.count}');
    return query.count;

    var myRef = FirebaseFirestore.instance.collection('ProjectEntry');
    var snapshot = await myRef.count().get();
    //print('collection Sum ${snapshot.count}');
  }

  _gotoSampleEntry() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SampleEntry()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Project'),
          backgroundColor: Colors.purple,
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: controller_projectName,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value!.isEmpty)
                      return "Please enter project name";
                    else
                      return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Project Name',
                  ),
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 30,
                ),
                RoundButton(
                  title: 'Save Data',
                  loading: loading,
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        loading = true;
                      });

                      if (!await IsProjectExists(controller_projectName.text)) {
                        final projectModels = FirebaseFirestore.instance
                            .collection('ProjectEntry');

                        try {
                          projectModels
                              .add({
                                'id': DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                                'projectName': controller_projectName.text
                              })
                              .then((value) {})
                              .onError((error, stackTrace) {
                                Utils().toastMessage(error.toString());
                                setState(() {
                                  loading = false;
                                });
                              });

                          Utils().toastMessage('Project Created');
                          setState(() {
                            loading = false;
                          });
                          _clearField();
                        } catch (e) {
                          Utils().toastMessage(e.toString());
                        } finally {}
                      }
                    }
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                RoundButton(
                  title: 'Sample Entry',
                  onTap: () {
                    _gotoSampleEntry();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

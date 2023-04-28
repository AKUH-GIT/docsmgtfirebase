import 'package:docsmgtfirebase/ui/Model/ProjectModel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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

  TextEditingController controller_projectName = new TextEditingController();

  late List<ProjectModel> lst_project = [];

  var focusNode = FocusNode();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final databaseRef = FirebaseDatabase.instance.ref('ProjectEntry');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Project')),
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
              ),
              const SizedBox(
                height: 30,
              ),
              RoundButton(
                title: 'Save Data',
                loading: loading,
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      loading = true;
                    });
                    databaseRef
                        .child(DateTime.now().millisecondsSinceEpoch.toString())
                        .set({
                      'projectName': controller_projectName.text.toString(),
                      'id': DateTime.now().millisecondsSinceEpoch.toString()
                    }).then((value) {
                      Utils().toastMessage('Project Added');
                      setState(() {
                        loading = false;
                      });
                    }).onError((error, stackTrace) {
                      Utils().toastMessage(error.toString());
                      setState(() {
                        loading = false;
                      });
                    });
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

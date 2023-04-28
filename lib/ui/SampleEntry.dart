import 'dart:io';
import 'package:docsmgtfirebase/ui/Model/ProjectModel.dart';
import 'package:docsmgtfirebase/ui/ProjectEntry.dart';
import 'package:docsmgtfirebase/ui/auth/LoginScreen.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Path;
import 'dart:convert';
import '../utils/Utils.dart';
import '../widgets/RoundButton.dart';

class SampleEntry extends StatefulWidget {
  const SampleEntry({Key? key}) : super(key: key);

  @override
  State<SampleEntry> createState() => SampleEntryState();
}

class SampleEntryState extends State<SampleEntry> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  TextEditingController controller_projectID = new TextEditingController();
  TextEditingController controller_sampleID = new TextEditingController();
  TextEditingController controller_imgpath = new TextEditingController();

  late List<ProjectModel> lst_project = [];

  var focusNode = FocusNode();
  var _image;

  FilePickerResult? result;
  String? fileName;
  PlatformFile? pickedFile, pickedFile_new;

  //XFile file;
  File? fileToDisplay, fileToDisplay_new;

  get ext => null;

  @override
  void initState() {
    super.initState();
    _readData();
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final databaseRef = FirebaseDatabase.instance.ref('SampleEntry');
  final databaseRefProject = FirebaseDatabase.instance.ref('ProjectEntry');

  void _clearField() {
    _formKey.currentState!.reset();
    controller_projectID.text = "";
    controller_sampleID.text = "";
    controller_imgpath.text = "";
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

  Future getDocs_Gallery() async {
    try {
      if (Platform.isAndroid) {
        result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowMultiple: false,
            allowedExtensions: [
              "jpg",
              "jpeg",
              "png",
              "doc",
              "docx",
              "xls",
              "xlsx",
              "mp4",
              "mp3",
              "avi",
              "pdf",
              "txt"
            ]);

        if (result != null) {
          fileName = result!.files.first.name;
          pickedFile = result!.files.first;
          pickedFile_new = result!.files.first;
          fileToDisplay = File(pickedFile_new!.path.toString());

          var arr = fileToDisplay!.path.split("/");
          var ext = arr[7].split('.');

          controller_imgpath.text = controller_projectID.text +
              "_" +
              controller_sampleID.text +
              "." +
              ext[1];

          var dir = await getExternalStorageDirectory();
          var arr_dir = dir!.path.split('/');

          fileToDisplay_new = File(arr_dir[0] +
              "/" +
              arr_dir[1] +
              "/" +
              arr_dir[2] +
              "/" +
              arr_dir[3] +
              "/DCIM/" +
              controller_projectID.text +
              "/" +
              controller_projectID.text +
              "_" +
              controller_sampleID.text +
              "." +
              ext[1]);
        } else {
          // User canceled the picker
        }
      }
    } catch (e) {
      showAlertDialog(context, e.toString());
      print(e.toString());
    }
  }

  saveProjectValue(ProjectModel projmodel) async {
    controller_projectID.text = projmodel.projectName!;
  }

  _gotoCreateProject() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProjectEntry()));
  }

  _gotologin() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  Future<List<ProjectModel>> _readData() async {
    Query needsSnapshot = await FirebaseDatabase.instance
        .reference()
        .child("ProjectEntry")
        .orderByKey();

    print(needsSnapshot);
    List<ProjectModel> projModel = [];

    Map<dynamic, dynamic> values = needsSnapshot as Map;
    values.forEach((key, values) {
      projModel.add(values);
    });

    return projModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Sample')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              DropdownSearch<ProjectModel>(
                items: lst_project,
                mode: Mode.DIALOG,
                validator: (value) {
                  if (value == null) {
                    return "Project name required";
                  }
                },
                showSearchBox: true,
                onChanged: (ProjectModel? projmodel) {
                  saveProjectValue(projmodel!);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: controller_sampleID,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value!.isEmpty)
                    return "Participant / Case ID required";
                  else
                    return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Participant / Case ID',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                readOnly: true,
                controller: controller_imgpath,
                /*validator: (value) {
                  if (value.isEmpty)
                    return "Please select image to upload";
                  else
                    return null;
                },*/
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Sample Image',
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              RoundButton(
                title: "Pick Image from Gallery",
                onTap: () {
                  getDocs_Gallery();
                  //_handleURLButtonPress(context, ImageSourceType.gallery);
                },
              ),
              const SizedBox(
                height: 30,
              ),
              RoundButton(
                title: "Pick Image from Camera",
                onTap: () {
                  //getDocs_Gallery();
                  _readData();
                  //_handleURLButtonPress(context, ImageSourceType.camera);
                },
              ),
              const SizedBox(
                height: 30,
              ),
              RoundButton(
                  title: "Create Project",
                  onTap: () {
                    _gotoCreateProject();
                  }),
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
                      'projectid': controller_projectID.text.toString(),
                      'sampleid': controller_sampleID.text.toString(),
                      'id': DateTime.now().millisecondsSinceEpoch.toString()
                    }).then((value) {
                      Utils().toastMessage('Record saved successfully');
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
              ),
              const SizedBox(
                height: 30,
              ),
              RoundButton(
                title: "Logout",
                onTap: () {
                  _gotologin();
                },
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

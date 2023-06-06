import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docsmgtfirebase/ui/Model/ProjectModel.dart';
import 'package:docsmgtfirebase/ui/ProjectEntry.dart';
import 'package:docsmgtfirebase/ui/ViewFiles.dart';
import 'package:docsmgtfirebase/ui/auth/LoginScreen.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Path;
import 'dart:convert';
import '../utils/Utils.dart';
import '../widgets/RoundButton.dart';
import 'package:flutter/foundation.dart'
    show Uint8List, defaultTargetPlatform, kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

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
  String var_img = "";

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
    getProjects();
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<ProjectModel>> getProjects() async {
    var collection = FirebaseFirestore.instance.collection('ProjectEntry');
    var querySnapshot = await collection.get();

    for (var queryDocumentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data = queryDocumentSnapshot.data();
      ProjectModel prjModel = new ProjectModel();
      prjModel.id = data['id'];
      prjModel.projectName = data['projectName'];
      lst_project.add(prjModel);
    }

    return lst_project;
  }

  _clearField() {
    //_formKey.currentState!.reset();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SampleEntry()));
    /*controller_projectID.text = "";
    controller_sampleID.text = "";
    controller_imgpath.text = "";*/
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

  Future getDocs_Gallery_SDCARD() async {
    try {


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
              "/Download/" +
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

        Utils().toastMessage("I m web - ");
      }
    } catch (e) {
      showAlertDialog(context, e.toString());
      print(e.toString());
    }
  }

  /// A new string is uploaded to storage.
  UploadTask uploadString() {
    const String putStringText =
        'This upload has been generated using the putString method! Check the metadata too!';

    // Create a Reference to the file
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('flutter-tests')
        .child('/put-string-example.txt');

    // Start upload of putString
    return ref.putString(
      putStringText,
      metadata: SettableMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'example': 'putString'},
      ),
    );
  }

  Future getDocs_Gallery_Firestore() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android) {
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
              "/Download/" +
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
      } else {
        FilePickerResult? result = await FilePicker.platform.pickFiles();
        String fileName = "";

        if (result != null) {
          Uint8List? fileBytes = result.files.first.bytes;
          fileName = result.files.first.name;
          pickedFile_new = result.files.first;
          controller_imgpath.text = result.files.first.name;

          //fileToDisplay = File(pickedFile_new!.path.toString());

          //var arr = fileToDisplay!.path.split("/");
          //var ext = arr[7].split('.');
        }

        Utils().toastMessage("I m web - ");
      }
    } catch (e) {
      showAlertDialog(context, e.toString());
      print(e.toString());
    }
  }

  Future saveFilePermanently() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android) {
        final Directory? appDocDir = await getExternalStorageDirectory();
        var arr = appDocDir!.path.split('/');

        Directory? appDocDirFolder = Directory(arr[0] +
            "/" +
            arr[1] +
            "/" +
            arr[2] +
            "/" +
            arr[3] +
            '/Download/docsmgtsys/${controller_projectID.text}/');

        var_img = Path.basename(appDocDirFolder.path);

        var arr1 = pickedFile!.path!.split('/');
        var ext = arr1[7].split('.');

        if (await appDocDirFolder.exists()) {
          //if folder already exists return path
        } else {
          //if folder not exists create folder and then return its path

          //final Directory _appDocDirNewFolder = await _appDocDirFolder.create(recursive: true);
          appDocDirFolder = await appDocDirFolder.create(recursive: true);
        }

        print(pickedFile_new!.path! +
            " - " +
            appDocDirFolder.path +
            ext![1] +
            " - " +
            fileToDisplay!.path);

        File(pickedFile!.path!).copySync(appDocDirFolder.path +
            controller_projectID.text +
            "_" +
            controller_sampleID.text +
            "." +
            ext[1]);

        //fileToDisplay!.copySync(appDocDirFolder.path + controller_imgpath.text);

        //final file = await File(pickedFile.path + '/Traders/Report').create(recursive: true);
        //file.writeAsStringSync("Hello I'm writting a stackoverflow answer into you");

        //newFile.copySync(_appDocDirFolder.path + arr[7]);

        /*String outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Please select an output file:',
          fileName: controller_imgpath.text,
        );

        if (outputFile == null) {
          // User canceled the picker
        }*/
      } else {
        final file = result!.files.first;
        final filePath = file.path;
        final mimeType = filePath != null ? lookupMimeType(filePath) : null;
        final contentType = mimeType != null ? MediaType.parse(mimeType) : null;

        final fileReadStream = file.readStream;
        if (fileReadStream == null) {
          throw Exception('Cannot read file from null stream');
        }
        final stream = http.ByteStream(fileReadStream);

        final uri = Uri.https('http://CLS-PAE-FP60088/docsmgtsys/test.php',
            '/flutterwebapp/skyfile');
        final request = http.MultipartRequest('POST', uri);
        final multipartFile = http.MultipartFile(
          'file',
          stream,
          file.size,
          filename: file.name,
          contentType: contentType,
        );
        request.files.add(multipartFile);

        final httpClient = http.Client();
        final response = await httpClient.send(request);

        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }

        final body = await response.stream.transform(utf8.decoder).join();

        print(body);

        Utils().toastMessage("I am web -- save function ");
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

  _gotoSearchSample() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ViewFiles()));
  }

  _saveData() {
    var sampleEntry = FirebaseFirestore.instance.collection("SampleEntry");

    sampleEntry
        .add({
          "id": DateTime.now().millisecondsSinceEpoch.toString(),
          "projectName": controller_projectID.text,
          "sampleID": controller_sampleID.text,
          "imgPath": controller_imgpath.text,
          "img": var_img,
        })
        .then((value) {})
        .onError((error, stackTrace) {
          Utils().toastMessage(error.toString());
          setState(() {
            loading = false;
          });
        });

    Utils().toastMessage('Sample successfully entered');
    setState(() {
      loading = false;
    });
    saveFilePermanently();
    _clearField();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Sample'),
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
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  readOnly: true,
                  controller: controller_imgpath,
                  validator: (value) {
                    if (value!.isEmpty)
                      return "Please select image to upload";
                    else
                      return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Sample Image',
                  ),
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 30,
                ),
                RoundButton(
                  title: "Pick Image from Gallery",
                  onTap: () {
                    getDocs_Gallery_Firestore();
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
                    setState(() {
                      loading = true;
                    });

                    if (_formKey.currentState!.validate()) {
                      _saveData();
                    }
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                RoundButton(
                  title: "View Files",
                  onTap: () {
                    _gotoSearchSample();
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
      ),
    );
  }
}

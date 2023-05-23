import 'package:flutter/material.dart';
import 'package:docsmgtfirebase/ui/SampleEntry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/Utils.dart';
import '../widgets/RoundButton.dart';
import 'package:flutter/foundation.dart';

class SearchSample extends StatefulWidget {
  const SearchSample({Key? key}) : super(key: key);

  @override
  SearchSampleState createState() => new SearchSampleState();
}

class SearchSampleState extends State<SearchSample> {
  TextEditingController SampleIDController = TextEditingController();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String btnText = "";

  var focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Search Sample'),
          backgroundColor: Colors.purple,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: SampleIDController,
                  autofocus: true,
                  focusNode: focusNode,
                  validator: (value) {
                    if (value!.isEmpty)
                      return "Sample id required";
                    else
                      return null;
                  },
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Sample ID'),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              RoundButton(
                title: 'Search Data',
                loading: loading,
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      loading = true;
                    });

                    final projectModels =
                        FirebaseFirestore.instance.collection('SampleEntry');
                  }
                },
              ),
              SizedBox(
                height: 30,
              ),
              RoundButton(
                title: 'Cancel',
                loading: loading,
                onTap: _clearField,
              ),
              SizedBox(
                height: 30,
              ),
              RoundButton(
                title: 'Sample Entry',
                onTap: _gotoSampleEntry,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _gotoSampleEntry() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => new SampleEntry()));
  }

  void _searchSampleID() async {}

  void _clearField() {
    _formKey.currentState!.reset();
    SampleIDController.text = "";
  }

  void _submit() {
    if (this._formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _searchSampleID();
    }
  }
}

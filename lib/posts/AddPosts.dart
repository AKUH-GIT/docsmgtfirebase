import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../utils/Utils.dart';
import '../widgets/RoundButton.dart';

class AddPosts extends StatefulWidget {
  const AddPosts({Key? key}) : super(key: key);

  @override
  State<AddPosts> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPosts> {
  final postController = TextEditingController();
  bool loading = false;
  final databaseRef = FirebaseDatabase.instance.ref('Post');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add Post')),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              TextFormField(
                maxLines: 4,
                controller: postController,
                decoration: InputDecoration(
                    hintText: 'What is in your mind?',
                    border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 30,
              ),
              RoundButton(
                title: 'Add',
                loading: loading,
                onTap: () {
                  setState(() {
                    loading = true;
                  });
                  databaseRef
                      .child(DateTime.now().millisecondsSinceEpoch.toString())
                      .set({
                    'title': postController.text.toString(),
                    'id': DateTime.now().millisecondsSinceEpoch.toString()
                  }).then((value) {
                    Utils().toastMessage('Post Added');
                    setState(() {
                      loading = false;
                    });
                  }).onError((error, stackTrace) {
                    Utils().toastMessage(error.toString());
                    setState(() {
                      loading = false;
                    });
                  });
                },
              )
            ],
          ),
        ));
  }
}

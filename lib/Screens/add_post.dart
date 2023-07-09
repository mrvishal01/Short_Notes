import 'package:crud/Screens/home_screen.dart';
import 'package:crud/Utils/utility.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final databaseRef = FirebaseDatabase.instance.ref('Notes');
  final postController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Notes"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            //const SizedBox(height: 20),
            TextField(
              controller: postController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Write Something...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    loading = true;
                  });
                  String id = DateTime.now().millisecond.toString();
                  databaseRef.child(id).set({
                    'title': postController.text.toString(),
                    'id': id,
                  }).then((value) {
                    Utils().toastMessage("Post Added");
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Home()));
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
                child: Center(
                  child: loading
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        )
                      : const Text("Add"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

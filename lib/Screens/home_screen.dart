import 'package:crud/Screens/add_post.dart';
import 'package:crud/Screens/login_screen.dart';
import 'package:crud/Utils/utility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final auth = FirebaseAuth.instance;
  final refDataBase = FirebaseDatabase.instance.ref('Notes');
  final searchController = TextEditingController();
  final editController = TextEditingController();

  Future<void> googleLogout() async {
    await GoogleSignIn().disconnect();
    FirebaseAuth.instance.signOut();
  }

  void emailLogout() async {
    auth.signOut().then((value) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }).onError((error, stackTrace) {
      debugPrint(error.toString());
      Utils().toastMessage(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return 
      WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Notes'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                googleLogout();
                emailLogout();
              },
              icon: const Icon(Icons.logout),
            )
          ],
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextFormField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: "Search",
                  border: OutlineInputBorder(),
                ),
                onChanged: (String value) {
                  setState(() {});
                },
              ),
            ),
            // Expanded(
            //   child: StreamBuilder(
            //       stream: refDataBase.onValue,
            //       builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
            //         if (!snapshot.hasData) {
            //           return const CircularProgressIndicator();
            //         } else {
            //           Map<dynamic, dynamic> map =
            //               snapshot.data!.snapshot.value as dynamic;
            //           List<dynamic> list = [];
            //           list.clear();
            //           list = map.values.toList();
            //           return ListView.builder(
            //               itemCount: snapshot.data!.snapshot.children.length,
            //               itemBuilder: ((context, index) {
            //                 return ListTile(
            //                   title: Text(list[index]['title']),
            //                 );
            //               }));
            //         }
            //       }),
            // ),
            Expanded(
              child: FirebaseAnimatedList(
                  query: refDataBase,
                  itemBuilder: (context, snapshot, animation, index) {
                    final title = snapshot.child('title').value.toString();
    
                    if (searchController.text.isEmpty) {
                      return ListTile(
                          title: Text(snapshot.child('title').value.toString()),
                          trailing: PopupMenuButton(
                            icon: const Icon(Icons.more_vert),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                  value: 1,
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.pop(context);
                                      showMyUpdateDilog(title,
                                          snapshot.child('id').value.toString());
                                    },
                                    leading: const Icon(Icons.edit),
                                    title: const Text('Edit'),
                                  )),
                              PopupMenuItem(
                                  child: ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  refDataBase
                                      .child(
                                          snapshot.child('id').value.toString())
                                      .remove();
                                },
                                leading: const Icon(Icons.delete),
                                title: const Text('Delete'),
                              )),
                            ],
                          ));
                    } else if (title.toLowerCase().contains(
                        searchController.text.toLowerCase().toString())) {
                      return ListTile(
                        title: Text(snapshot.child('title').value.toString()),
                      );
                    } else {
                      return Container();
                    }
                  }),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddPost()));
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> showMyUpdateDilog(String title, String id) async {
    editController.text = title;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Update"),
            content: TextField(
              controller: editController,
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    refDataBase.child(id).update  ({
                      'title': editController.text,
                    }).then((value) {
                      Utils().toastMessage("Successfully Updated");
                    }).onError((error, stackTrace) {
                      Utils().toastMessage(error.toString());
                    });
                  },
                  child: const Text('Update')),
            ],
          );
        });
  }

  
}

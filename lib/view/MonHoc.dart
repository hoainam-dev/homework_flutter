import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MonHoc extends StatefulWidget {
  const MonHoc({Key? key}) : super(key: key);

  @override
  State<MonHoc> createState() => _MonHocState();
}

class _MonHocState extends State<MonHoc> {
  TextEditingController _idmhController = new TextEditingController();
  TextEditingController _subjectNameController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();

  final CollectionReference _subject =
  FirebaseFirestore.instance.collection('subject');

  final _formKey = GlobalKey<FormState>();

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _idmhController.text = documentSnapshot['idmh'];
      _subjectNameController.text = documentSnapshot['subjectName'];
      _descriptionController = documentSnapshot['description'];
    }
    print(action);

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Container(
            margin: EdgeInsets.fromLTRB(10, 50, 10, 0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("${action} Subject", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text("ID Môn học:"),
                  TextFormField(
                    controller: _idmhController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Text("Tên môn học:"),
                  TextFormField(
                    controller: _subjectNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Text("Mô tả:"),
                  TextFormField(
                    controller: _descriptionController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    child: Text(action == 'create' ? 'Create' : 'Update'),
                    onPressed: () async {
                      final String? idmh = _idmhController.text;
                      final String? subjectName = _subjectNameController.text;
                      final String? description = _descriptionController.text;
                      if (idmh != null && subjectName != null && description != null) {
                        if (action == 'create') {
                          // Persist a new product to Firestore
                          await _subject.add({"idmh": idmh,
                            "subjectName": subjectName,
                            "description": description,
                          });
                        }

                        if (action == 'update') {
                          // Update the product
                          await _subject
                              .doc(documentSnapshot!.id)
                              .update({"idmh": idmh,
                            "subjectName": subjectName,
                            "description": description,
                          });
                        }

                        // Clear the text fields
                        _idmhController.text = '';
                        _subjectNameController.text = '';
                        _descriptionController.text = '';

                        // Hide the bottom sheet
                        Navigator.of(context).pop();
                      }
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("You have successfully ${action} a subject")));
                    },
                  )
                ],
              ),
            ),
          );
        });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("You have successfully ${action} a subject")));
  }

  // Deleteing a product by id
  Future<void> _deleteSubject(String subjectId) async {
    await _subject.doc(subjectId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a subject')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Subject")),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: StreamBuilder(
        stream: _subject.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['idmh']),
                    subtitle: Column(
                      children: [
                        Row(
                          children: [
                            Text("SubjectName: "),
                            Text(documentSnapshot['subjectName']),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Description: "),
                            Container(
                              width: 130,
                              child:
                              Text(documentSnapshot['description'], overflow: TextOverflow.ellipsis,),
                            )
                          ],
                        ),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          // Press this button to edit a single product
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _createOrUpdate(documentSnapshot)),
                          // This icon button is used to delete a single product
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteSubject(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      // Add new product
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

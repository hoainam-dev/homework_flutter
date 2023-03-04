import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LopHoc extends StatefulWidget {
  const LopHoc({Key? key}) : super(key: key);

  @override
  State<LopHoc> createState() => _LopHocState();
}

class _LopHocState extends State<LopHoc> {
  TextEditingController _idlhController = new TextEditingController();
  TextEditingController _classNameController = new TextEditingController();
  TextEditingController _numOfStudentController = new TextEditingController();
  TextEditingController _idgvController = new TextEditingController();

  final CollectionReference _class =
  FirebaseFirestore.instance.collection('class');

  final _formKey = GlobalKey<FormState>();

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _idlhController.text = documentSnapshot['idlh'];
      _classNameController.text = documentSnapshot['className'];
      _numOfStudentController.text = documentSnapshot['numOfStudent'].toString();
      _idgvController.text = documentSnapshot['idgv'];
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
                      Text("${action} Class", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text("ID Lớp học:"),
                  TextFormField(
                    controller: _idlhController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Text("Tên lớp:"),
                  TextFormField(
                    controller: _classNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Text("Số lượng sinh viên:"),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _numOfStudentController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Text("Mã giảng viên:"),
                  TextFormField(
                    controller: _idgvController,
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
                      final String? idlh = _idlhController.text;
                      final String? className = _classNameController.text;
                      final int? numOfStudent = int.tryParse(_numOfStudentController.text);
                      final String? idgv = _idgvController.text;
                      if (idlh != null && className != null && numOfStudent != null && idgv != null) {
                        if (action == 'create') {
                          // Persist a new product to Firestore
                          await _class.add({"idlh": idlh,
                            "className": className,
                            "numOfStudent": numOfStudent,
                            "idgv": idgv,
                          });
                        }

                        if (action == 'update') {
                          // Update the product
                          await _class
                              .doc(documentSnapshot!.id)
                              .update({"idlh": idlh,
                            "className": className,
                            "numOfStudent": numOfStudent,
                            "idgv": idgv,
                          });
                        }

                        // Hide the bottom sheet
                        Navigator.of(context).pop();
                      }
                    },
                  )
                ],
              ),
            ),
          );
        });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("You have successfully ${action} a class")));
  }

  // Deleteing a product by id
  Future<void> _deleteClass(String classId) async {
    await _class.doc(classId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a class')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Class")),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: StreamBuilder(
        stream: _class.snapshots(),
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
                    title: Text(documentSnapshot['idlh']),
                    subtitle: Column(
                      children: [
                        Row(
                          children: [
                            Text("Tên lớp: "),
                            Text(documentSnapshot['className']),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Số lượng sinh viên: "),
                            Text(documentSnapshot['numOfStudent'].toString()),

                          ],
                        ),
                        Row(
                          children: [
                            Text("Mã giảng viên: "),
                            Text(documentSnapshot['idgv']),
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
                                  _deleteClass(documentSnapshot.id)),
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

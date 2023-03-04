import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GiangVien extends StatefulWidget {
  const GiangVien({Key? key}) : super(key: key);

  @override
  State<GiangVien> createState() => _GiangVienState();
}

class _GiangVienState extends State<GiangVien> {
  TextEditingController _idgvController = new TextEditingController();
  TextEditingController _fullNameController = new TextEditingController();
  TextEditingController _addressController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();

  final CollectionReference _teacher =
  FirebaseFirestore.instance.collection('teacher');

  final _formKey = GlobalKey<FormState>();

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _idgvController.text = documentSnapshot['idgv'];
      _fullNameController.text = documentSnapshot['fullName'];
      _addressController.text = documentSnapshot['address'];
      _phoneController.text = documentSnapshot['phone'];
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
                      Text("${action} Teacher", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text("ID Giảng viên:"),
                  TextFormField(
                    controller: _idgvController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Text("Họ và tên:"),
                  TextFormField(
                    controller: _fullNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Text("Địa chỉ:"),
                  TextFormField(
                    controller: _addressController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Text("Số điện thoại:"),
                  TextFormField(
                    controller: _phoneController,
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
                      final String? idgv = _idgvController.text;
                      final String? fullName = _fullNameController.text;
                      final String? address = _addressController.text;
                      final String? phone = _phoneController.text;
                      if (idgv != null && fullName != null && address != null && phone != null) {
                        if (action == 'create') {
                          // Persist a new product to Firestore
                          await _teacher.add({"idgv": idgv,
                            "fullName": fullName,
                            "address": address,
                            "phone": phone,
                          });
                        }

                        if (action == 'update') {
                          // Update the product
                          await _teacher
                              .doc(documentSnapshot!.id)
                              .update({"idgv": idgv,
                            "fullName": fullName,
                            "address": address,
                            "phone": phone,
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
        content: Text("You have successfully ${action} a Teacher")));
  }

  // Deleteing a product by id
  Future<void> _deleteTeacher(String teacherId) async {
    await _teacher.doc(teacherId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a teacher')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Teacher")),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: StreamBuilder(
        stream: _teacher.snapshots(),
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
                    title: Text(documentSnapshot['idgv']),
                    subtitle: Column(
                      children: [
                        Row(
                          children: [
                            Text("FullName: "),
                            Text(documentSnapshot['fullName']),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Address: "),
                            Text(documentSnapshot['address']),

                          ],
                        ),
                        Row(
                          children: [
                            Text("Phone: "),
                            Text(documentSnapshot['phone']),
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
                                  _deleteTeacher(documentSnapshot.id)),
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

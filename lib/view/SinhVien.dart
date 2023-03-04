import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SinhVien extends StatefulWidget {
  const SinhVien({Key? key}) : super(key: key);

  @override
  State<SinhVien> createState() => _SinhVienState();
}

class _SinhVienState extends State<SinhVien> {
  TextEditingController _idsvController = new TextEditingController();
  TextEditingController _dobController = new TextEditingController();
  TextEditingController _adddressController = new TextEditingController();

  String? _gender;
  final _formKey = GlobalKey<FormState>();

  final CollectionReference _student =
  FirebaseFirestore.instance.collection('student');

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _idsvController.text = documentSnapshot['idsv'];
      _dobController.text = documentSnapshot['dob'];
      _gender = documentSnapshot['gender'];
      _adddressController.text = documentSnapshot['address'];
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
                      Text("${action} Student", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text("IDSV:"),
                  TextFormField(
                    controller: _idsvController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Text("Ngày sinh:"),
                  TextField(
                    controller: _dobController,
                    //editing controller of this TextField
                    decoration: InputDecoration(
                        icon: Icon(Icons.calendar_today), //icon of text field
                        labelText: "Enter Date" //label text of field
                    ),
                    readOnly: true,
                    //set it true, so that user will not able to edit text
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1950),
                          //DateTime.now() - not to allow to choose before today.
                          lastDate: DateTime(2100));

                      if (pickedDate != null) {
                        print(
                            pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                        String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                        print(
                            formattedDate); //formatted date output using intl package =>  2021-03-16
                        setState(() {
                          _dobController.text =
                              formattedDate; //set output date to TextField value.
                        });
                      } else {}
                    },
                  ),
                  SizedBox(height: 10),
                  Text("Giới tính:"),
                  Column(
                    children: [
                      RadioListTile(
                        title: Text('Male'),
                        value: "male",
                        groupValue: _gender,
                        onChanged: (value) {
                          setState(() {
                            _gender = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('Female'),
                        value: "female",
                        groupValue: _gender,
                        onChanged: (value) {
                          setState(() {
                            _gender = value.toString();
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text("Địa chỉ:"),
                  TextFormField(
                    controller: _adddressController,
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
                      final String? idsv = _idsvController.text;
                      final String? dob = _dobController.text;
                      final String? gender = _gender;
                      final String? address = _adddressController.text;
                      if (idsv != null && dob != null && gender != null && address != null) {
                        if (action == 'create') {
                          // Persist a new product to Firestore
                          await _student.add({"idsv": idsv,
                            "dob": dob,
                            "gender": gender,
                            "address": address,
                          });
                        }

                        if (action == 'update') {
                          // Update the product
                          await _student
                              .doc(documentSnapshot!.id)
                              .update({"idsv": idsv,
                            "dob": dob,
                            "gender": gender,
                            "address": address,
                          });
                        }

                        // Clear the text fields
                        _idsvController.text = '';
                        _dobController.text = '';
                        _adddressController.text = '';

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
        content: Text("You have successfully ${action} a student")));
  }

  // Deleteing a product by id
  Future<void> _deleteStudent(String studentId) async {
    await _student.doc(studentId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a student')));
  }

  @override
  void initState() {
    _dobController.text = ""; //set the initial value of text field
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Student")),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: StreamBuilder(
        stream: _student.snapshots(),
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
                    title: Text(documentSnapshot['idsv']),
                    subtitle: Column(
                      children: [
                        Row(
                          children: [
                            Text("Day of birth: "),
                            Text(documentSnapshot['dob']),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Gender: "),
                            Text(documentSnapshot['gender']),

                          ],
                        ),
                        Row(
                          children: [
                            Text("Address: "),
                            Text(documentSnapshot['address']),
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
                                  _deleteStudent(documentSnapshot.id)),
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

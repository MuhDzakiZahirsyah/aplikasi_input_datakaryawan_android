import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddBranchPage extends StatefulWidget {
  @override
  _AddBranchPageState createState() => _AddBranchPageState();
}

class _AddBranchPageState extends State<AddBranchPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  List<Map<String, dynamic>> branches = [];
  bool isEditing = false;
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    fetchBranches();
  }

  Future<void> fetchBranches() async {
    final response = await http.get(
      Uri.parse('https://mobilecomputing.my.id/api_dzaki/branch.php?action=read'),
    );

    if (response.statusCode == 200) {
      setState(() {
        branches = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    }
  }

  Future<void> createBranch() async {
    final String name = _nameController.text;
    final String location = _locationController.text;
    final String phone = _phoneController.text;

    if (name.isEmpty || location.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('All fields are required'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final response = await http.post(
      Uri.parse('https://mobilecomputing.my.id/api_dzaki/branch.php?action=create'),
      body: {
        'name': name,
        'location': location,
        'phone': phone,
      },
    );

    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Branch created successfully'),
        backgroundColor: Colors.green,
      ));

      setState(() {
        branches.add({
          'id': responseBody['id'],
          'name': name,
          'location': location,
          'phone': phone,
        });

        _nameController.clear();
        _locationController.clear();
        _phoneController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to create branch: ${responseBody['message']}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> updateBranch(int index) async {
    final String id = branches[index]['id'].toString(); // Pastikan id diambil dengan benar
    final String name = _nameController.text;
    final String location = _locationController.text;
    final String phone = _phoneController.text;

    if (name.isEmpty || location.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('All fields are required'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final response = await http.post(
      Uri.parse('https://mobilecomputing.my.id/api_dzaki/branch.php?action=update'),
      body: {
        'id': id,
        'name': name,
        'location': location,
        'phone': phone,
      },
    );

    print('Updating branch with ID: $id');
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Branch updated successfully'),
        backgroundColor: Colors.green,
      ));

      setState(() {
        branches[index] = {
          'id': id,
          'name': name,
          'location': location,
          'phone': phone,
        };

        _nameController.clear();
        _locationController.clear();
        _phoneController.clear();
        isEditing = false;
        editingIndex = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update branch: ${responseBody['message']}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> deleteBranch(int index) async {
    final String id = branches[index]['id'].toString(); // Pastikan id diambil dengan benar

    final response = await http.post(
      Uri.parse('https://mobilecomputing.my.id/api_dzaki/branch.php?action=delete'),
      body: {
        'id': id,
      },
    );

    print('Deleting branch with ID: $id');
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Branch deleted successfully'),
        backgroundColor: Colors.green,
      ));

      setState(() {
        branches.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete branch: ${responseBody['message']}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void startEditBranch(int index) {
    setState(() {
      _nameController.text = branches[index]['name'];
      _locationController.text = branches[index]['location'];
      _phoneController.text = branches[index]['phone'];
      isEditing = true;
      editingIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isEditing
                  ? () => updateBranch(editingIndex!)
                  : createBranch,
              child: Text(isEditing ? 'Update Branch' : 'Add Branch'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: branches.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(branches[index]['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Location: ${branches[index]['location']}'),
                          Text('Phone: ${branches[index]['phone']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              startEditBranch(index);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              deleteBranch(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

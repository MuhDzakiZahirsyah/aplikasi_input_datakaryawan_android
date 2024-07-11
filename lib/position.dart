import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPositionPage extends StatefulWidget {
  @override
  _AddPositionPageState createState() => _AddPositionPageState();
}

class _AddPositionPageState extends State<AddPositionPage> {
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Map<String, dynamic>> positions = [];
  bool isEditing = false;
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    fetchPositions();
  }

  Future<void> fetchPositions() async {
    final response = await http.get(
      Uri.parse('https://mobilecomputing.my.id/api_dzaki/position.php?action=read'),
    );

    if (response.statusCode == 200) {
      setState(() {
        positions = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    }
  }

  Future<void> createPosition() async {
    final String position = _positionController.text;
    final String department = _departmentController.text;
    final String description = _descriptionController.text;

    if (position.isEmpty || department.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('All fields are required'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final response = await http.post(
      Uri.parse('https://mobilecomputing.my.id/api_dzaki/position.php?action=create'),
      body: {
        'position': position,
        'department': department,
        'description': description,
      },
    );

    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Position created successfully'),
        backgroundColor: Colors.green,
      ));

      setState(() {
        positions.add({
          'id': responseBody['id'],
          'position_name': position,
          'department': department,
          'description': description,
        });

        _positionController.clear();
        _departmentController.clear();
        _descriptionController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to create position: ${responseBody['message']}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> updatePosition(int index) async {
    final String id = positions[index]['id'].toString();
    final String position = _positionController.text;
    final String department = _departmentController.text;
    final String description = _descriptionController.text;

    if (position.isEmpty || department.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('All fields are required'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final response = await http.post(
      Uri.parse('https://mobilecomputing.my.id/api_dzaki/position.php?action=update'),
      body: {
        'id': id,
        'position': position,
        'department': department,
        'description': description,
      },
    );

    print('Updating position with ID: $id');
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Position updated successfully'),
        backgroundColor: Colors.green,
      ));

      setState(() {
        positions[index] = {
          'id': id,
          'position_name': position,
          'department': department,
          'description': description,
        };

        _positionController.clear();
        _departmentController.clear();
        _descriptionController.clear();
        isEditing = false;
        editingIndex = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update position: ${responseBody['message']}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> deletePosition(int index) async {
    final String id = positions[index]['id'].toString();

    final response = await http.post(
      Uri.parse('https://mobilecomputing.my.id/api_dzaki/position.php?action=delete'),
      body: {
        'id': id,
      },
    );

    print('Deleting position with ID: $id');
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Position deleted successfully'),
        backgroundColor: Colors.green,
      ));

      setState(() {
        positions.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete position: ${responseBody['message']}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void startEditPosition(int index) {
    setState(() {
      _positionController.text = positions[index]['position_name'];
      _departmentController.text = positions[index]['department'];
      _descriptionController.text = positions[index]['description'];
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
              controller: _positionController,
              decoration: InputDecoration(labelText: 'Position'),
            ),
            TextField(
              controller: _departmentController,
              decoration: InputDecoration(labelText: 'Department'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isEditing
                  ? () => updatePosition(editingIndex!)
                  : createPosition,
              child: Text(isEditing ? 'Update Position' : 'Add Position'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: positions.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(positions[index]['position_name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Department: ${positions[index]['department']}'),
                          Text('Description: ${positions[index]['description']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              startEditPosition(index);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              deletePosition(index);
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

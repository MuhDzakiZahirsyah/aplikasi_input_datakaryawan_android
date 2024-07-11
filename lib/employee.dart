import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddEmployeePage extends StatefulWidget {
  @override
  _AddEmployeePageState createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final TextEditingController _nameController = TextEditingController();
  List branches = [];
  List positions = [];
  String? selectedBranch;
  String? selectedPosition;
  File? _image;

  @override
  void initState() {
    super.initState();
    fetchBranches();
    fetchPositions();
  }

  Future<void> fetchBranches() async {
    final response = await http.get(Uri.parse(
        'https://mobilecomputing.my.id/api_dzaki/branch.php?action=read'));

    if (response.statusCode == 200) {
      setState(() {
        branches = json.decode(response.body);
      });
    }
  }

  Future<void> fetchPositions() async {
    final response = await http.get(Uri.parse(
        'https://mobilecomputing.my.id/api_dzaki/position.php?action=read'));

    if (response.statusCode == 200) {
      setState(() {
        positions = json.decode(response.body);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<void> createEmployee() async {
    final String name = _nameController.text;

    if (name.isEmpty ||
        selectedBranch == null ||
        selectedPosition == null ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('All fields and image are required'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://mobilecomputing.my.id/api_dzaki/employee.php?action=create'),
    );

    request.fields['name'] = name;
    request.fields['office_id'] = selectedBranch!;
    request.fields['position_id'] = selectedPosition!;
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();
    print('Response status: ${response.statusCode}');
    print('Response body: $responseBody');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Employee created successfully'),
        backgroundColor: Colors.green,
      ));
    }
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
            DropdownButtonFormField<String>(
              value: selectedPosition,
              items: positions.map((position) {
                return DropdownMenuItem<String>(
                  value: position['id'].toString(),
                  child: Text(position['position_name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPosition = value;
                });
              },
              decoration: InputDecoration(labelText: 'Position'),
            ),
            DropdownButtonFormField<String>(
              value: selectedBranch,
              items: branches.map((branch) {
                return DropdownMenuItem<String>(
                  value: branch['id'].toString(),
                  child: Text(branch['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBranch = value;
                });
              },
              decoration: InputDecoration(labelText: 'Branch'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            _image != null ? Image.file(_image!) : Container(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: createEmployee,
              child: Text('Add Employee'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditEmployeePage extends StatefulWidget {
  final Map employee;

  EditEmployeePage({required this.employee});

  @override
  _EditEmployeePageState createState() => _EditEmployeePageState();
}

class _EditEmployeePageState extends State<EditEmployeePage> {
  final TextEditingController _nameController = TextEditingController();
  List branches = [];
  List positions = [];
  String? selectedBranch;
  String? selectedPosition;
  File? _image;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.employee['name'];
    selectedBranch = widget.employee['office_id'].toString();
    selectedPosition = widget.employee['position_id'].toString();
    fetchBranches();
    fetchPositions();
  }

  Future<void> fetchBranches() async {
    final response = await http.get(Uri.parse(
        'https://mobilecomputing.my.id/api_dzaki/branch.php?action=read'));

    if (response.statusCode == 200) {
      setState(() {
        branches = json.decode(response.body);
      });
    }
  }

  Future<void> fetchPositions() async {
    final response = await http.get(Uri.parse(
        'https://mobilecomputing.my.id/api_dzaki/position.php?action=read'));

    if (response.statusCode == 200) {
      setState(() {
        positions = json.decode(response.body);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<void> updateEmployee() async {
    final String name = _nameController.text;

    if (name.isEmpty || selectedBranch == null || selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('All fields are required'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://mobilecomputing.my.id/api_dzaki/employee.php?action=update'),
    );

    request.fields['id'] = widget.employee['id'].toString();
    request.fields['name'] = name;
    request.fields['office_id'] = selectedBranch!;
    request.fields['position_id'] = selectedPosition!;

    if (_image != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', _image!.path));
    }

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();
    print('Response status: ${response.statusCode}');
    print('Response body: $responseBody');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Employee updated successfully'),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Employee'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            DropdownButtonFormField<String>(
              value: selectedPosition,
              items: positions.map((position) {
                return DropdownMenuItem<String>(
                  value: position['id'].toString(),
                  child: Text(position['position_name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPosition = value;
                });
              },
              decoration: InputDecoration(labelText: 'Position'),
            ),
            DropdownButtonFormField<String>(
              value: selectedBranch,
              items: branches.map((branch) {
                return DropdownMenuItem<String>(
                  value: branch['id'].toString(),
                  child: Text(branch['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBranch = value;
                });
              },
              decoration: InputDecoration(labelText: 'Branch'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            _image != null
                ? Image.file(_image!)
                : widget.employee['image'] != null
                    ? Image.network(
                        'https://mobilecomputing.my.id/api_dzaki/${widget.employee['image']}',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : Container(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateEmployee,
              child: Text('Update Employee'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'position.dart';
import 'employee.dart';
import 'profile.dart';
import 'branch.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Apps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    final response = await http.post(
      Uri.parse('https://mobilecomputing.my.id/api_dzaki/login.php'),
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('username', username);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login Berhasil'),
          backgroundColor: Colors.green,
        ));
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Login Berhasil'),
              content: Text('Anda berhasil login!'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainPage()),
                    );
                  },
                ),
              ],
            );
          },
        );
      } else if (data['message'] == 'Invalid username or password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Username atau password salah.'),
          backgroundColor: Colors.red,
        ));
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Login Gagal'),
              content: Text('Username atau password salah.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Username atau password salah.'),
          backgroundColor: Colors.red,
        ));
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Login Gagal'),
              content: Text('Username atau password salah.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${response.reasonPhrase}'),
        backgroundColor: Colors.red,
      ));
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error: ${response.reasonPhrase}'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }




  Widget _buildUsernameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Username',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextField(
            controller: _usernameController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.black,
              ),
              hintText: 'Enter your Username',
              hintStyle: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.black,
              ),
              hintText: 'Enter your Password',
              hintStyle: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5.0,
          padding: EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: _login,
        child: Text(
          'LOGIN',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 120.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/logo.png', // pastikan Anda memiliki file gambar logo di folder assets Anda
                        height: 100,
                      ),
                      SizedBox(height: 30.0),
                      Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30.0),
                      _buildUsernameTF(),
                      SizedBox(height: 30.0),
                      _buildPasswordTF(),
                      SizedBox(
                          height:
                              30.0), // Menambahkan jarak antara password dan login button
                      _buildLoginBtn(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    HomePage(),
    AddEmployeePage(),
    AddBranchPage(),
    AddPositionPage(),
    ProfilePage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Apps'),
        backgroundColor: Color(0xFF398AE5),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            backgroundColor: Color(0xFF398AE5),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            backgroundColor: Color(0xFF398AE5),
            label: 'Add Employee',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city),
            backgroundColor: Color(0xFF398AE5),
            label: 'Add Branch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            backgroundColor: Color(0xFF398AE5),
            label: 'Add Position',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            backgroundColor: Color(0xFF398AE5),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List employees = [];
  Map<int, String> branchNames = {};

  @override
  void initState() {
    super.initState();
    fetchEmployees();
    fetchBranches();
  }

  Future<void> fetchEmployees() async {
    final response = await http.get(Uri.parse(
        'https://mobilecomputing.my.id/api_dzaki/employee.php?action=read'));
    if (response.statusCode == 200) {
      setState(() {
        employees = json.decode(response.body);
      });
    }
  }

  Future<void> fetchBranches() async {
    final response = await http.get(Uri.parse(
        'https://mobilecomputing.my.id/api_dzaki/branch.php?action=read'));
    if (response.statusCode == 200) {
      setState(() {
        List branches = json.decode(response.body);
        for (var branch in branches) {
          branchNames[int.parse(branch['id'])] = branch['name'];
        }
      });
    }
  }

  Future<void> deleteEmployee(int id) async {
    // Tampilkan dialog konfirmasi sebelum menghapus data
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah kamu yakin ingin menghapus data ini?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(false); // Kembalikan false jika batal
              },
            ),
            TextButton(
              child: Text('Hapus'),
              onPressed: () {
                Navigator.of(context).pop(true); // Kembalikan true jika yakin
              },
            ),
          ],
        );
      },
    );

    // Jika pengguna mengkonfirmasi penghapusan
    if (confirmDelete == true) {
      final response = await http.post(
        Uri.parse(
            'https://mobilecomputing.my.id/api_dzaki/employee.php?action=delete'),
        body: {'id': id.toString()},
      );

      if (response.statusCode == 200) {
        fetchEmployees();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Employee deleted successfully'),
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to delete employee'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }


  void navigateToEditEmployee(Map employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEmployeePage(employee: employee),
      ),
    ).then((value) {
      if (value == true) {
        fetchEmployees();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: employees.isEmpty
          ? Center(child: Text('Tidak ada data employee'))
          : ListView.builder(
        itemCount: employees.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10.0),
            child: ListTile(
              leading: employees[index]['image'] != null
                  ? Image.network(
                'https://mobilecomputing.my.id/api_dzaki/${employees[index]['image']}',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
                  : Image.asset(
                'assets/logo.png',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(employees[index]['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Position: ${employees[index]['position_name']}'),
                  Text(
                      'Branch: ${branchNames[int.parse(
                          employees[index]['office_id'])] ?? 'Unknown'}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      navigateToEditEmployee(employees[index]);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteEmployee(int.parse(employees[index]['id']));
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

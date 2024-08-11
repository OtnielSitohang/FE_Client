import 'package:client_front/pages/login_page.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tempatTinggalController =
      TextEditingController();
  DateTime? _tanggalLahir;
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscureText = true; // Added definition for obscureText
  final _formKey = GlobalKey<FormState>();

  void _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _usernameController.text;
    final password = _passwordController.text;
    final namaLengkap = _namaLengkapController.text;
    final email = _emailController.text;
    final tempatTinggal = _tempatTinggalController.text;
    final tanggalLahir = _tanggalLahir;

    try {
      await _authService.register(
          username, password, namaLengkap, email, tempatTinggal, tanggalLahir!);

      // Navigate to login page and remove the registration page from the navigation stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LoginPage()), // Assuming LoginPage is the login page
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _tanggalLahir) {
      setState(() {
        _tanggalLahir = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Icon(Icons.person, size: 100),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  icon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username is required';
                  }
                  // Add additional validation for uniqueness if needed
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  icon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                obscureText: _obscureText,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  if (!RegExp(
                          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$')
                      .hasMatch(value)) {
                    return 'Password must include letters, numbers, and special characters';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _namaLengkapController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  icon: Icon(Icons.person_add),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama Lengkap is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  icon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[^@]+@[^\.]+\..+').hasMatch(value)) {
                    return 'Email must contain @ and .';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _tempatTinggalController,
                decoration: InputDecoration(
                  labelText: 'Tempat Tinggal',
                  icon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tempat Tinggal is required';
                  }
                  return null;
                },
              ),
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: _tanggalLahir == null
                          ? 'Tanggal Lahir'
                          : '${_tanggalLahir!.toLocal()}'.split(' ')[0],
                      icon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (_tanggalLahir == null) {
                        return 'Tanggal Lahir is required';
                      }
                      final age = DateTime.now().year - _tanggalLahir!.year;
                      if (age < 18) {
                        return 'You must be at least 18 years old';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _register,
                      child: Text('Register'),
                    ),
              if (_errorMessage != null) ...[
                SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:todo/screens/Login.dart';

class Sign extends StatefulWidget {
  const Sign({super.key});
  @override
  State<Sign> createState() => _SignState();
}

class _SignState extends State<Sign> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  final globalkey = GlobalKey<FormState>();
  bool show = true;

  Future<bool> senddata(String email, String password) async {
    try {
      final res = await http.post(
          Uri.parse(
              'http://10.0.2.2:5000/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}));

          final resdata = jsonDecode(res.body);
          final message = resdata['message'];
      if (res.statusCode == 201) {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        return true;
      } else {
        Fluttertoast.showToast(
          msg: message ?? "Error occured ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return false;
      }
    } catch (r) {
      Fluttertoast.showToast(
          msg: 'Error: $r',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white);
      return false;
    }
  }

  void _sign() async {
    if (globalkey.currentState!.validate()) {
      String email = _email.text.trim();
      String password = _password.text.trim();
      bool issucess = await senddata(email, password);
      if (issucess) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Login()));
      }
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.purple.shade50,
        body: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                child: Icon(Icons.arrow_back),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Expanded(
                child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                      key: globalkey,
                      child: Column(
                        children: [
                          Text(
                            "Register Here",
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: _email,
                              decoration: InputDecoration(
                                  labelText: "Email",
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.email),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 2)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 2))),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Email';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                                  return 'Enter a Valid Email';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: _password,
                              decoration: InputDecoration(
                                  labelText: "Password",
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.password),
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          show = !show;
                                        });
                                      },
                                      icon: Icon(show
                                          ? Icons.visibility_off
                                          : Icons.visibility)),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 2)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 2))),
                              obscureText: show,
                              keyboardType: TextInputType.visiblePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Email';
                                }
                                if (value.length < 6) {
                                  return 'Password Must Be atleast 6 Characters';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _sign,
                                child: Text("Submit",
                                    style: TextStyle(fontSize: 18)),
                                style: ElevatedButton.styleFrom(),
                              ),
                            ),
                          )
                        ],
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "are you Already Register",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: 5),
                      GestureDetector(
                        child: Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 15),
                        ),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Login()));
                        },
                      )
                    ],
                  )
                ],
              ),
            )),
          ],
        )));
  }
}

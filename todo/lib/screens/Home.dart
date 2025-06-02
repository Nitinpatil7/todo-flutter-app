import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController input = TextEditingController();
  List<Map<String, dynamic>> tasks = [];
  String? editingid;

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  //get task from backend
  Future<void> fetchtasks() async {
    final token = await getToken();
    try {
      final res = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/todo'),
        headers: {
          'Content-Type': 'applicaion/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          tasks = data.cast<Map<String, dynamic>>();
        });
      } else {
        Fluttertoast.showToast(msg: "Failed to load tasks");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  //post task to backend
  Future<Map<String, dynamic>?> addtask(String text) async {
    final token = await getToken();
    print(token);
    try {
      final res = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/todo'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'text': text}),
      );

     

      if (res.statusCode == 200 || res.statusCode == 201) {
        final resdata = jsonDecode(res.body);
        Fluttertoast.showToast(
          msg: "Task Added SuccessFully!",
          backgroundColor: Colors.green,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
        );
        fetchtasks();
        return resdata;
      } else {
        Fluttertoast.showToast(
          msg: "Error Occured",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
        );
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
      return null;
    }
  }

  //update task in backend
  Future<bool> updatetask(String id, String newtext) async {
    final token = await getToken();
    try {
      final res = await http.put(
        Uri.parse("http://10.0.2.2:5000/api/todo/$id"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'text': newtext}),
      );
      if (res.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Task Updated Successfully!",
          backgroundColor: Colors.green,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
        );
        return true;
      } else {
        Fluttertoast.showToast(
          msg: "Failed to Update Task!",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
      return false;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error : $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
      return false;
    }
  }

  //delete task from backend
  Future<bool> deletetask(String id) async {
    final token = await getToken();
    try {
      final res = await http.delete(
        Uri.parse('http://10.0.2.2:5000/api/todo/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Deleted Successfully",
          backgroundColor: Colors.green,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
        );
        return true;
      } else {
        Fluttertoast.showToast(
          msg: "Failed to Delete task",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
        );
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error : $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
      return false;
    }
  }

  void clickhandler() async {
  
    String text = input.text.trim();
    if (text.isEmpty) return;

    if (editingid == null) {
      // ADD mode
      final res = await addtask(text);
      if (res != null) {
        setState(() {
          tasks.add({'_id': res['_id'], 'text': res['text']});
          input.clear();
        });
      }
    } else {
      // UPDATE mode
      final success = await updatetask(editingid!, text);
      if (success) {
        setState(() {
          tasks = tasks.map((task) {
            if (task['_id'] == editingid) {
              return {'_id': task['_id'], 'text': text};
            }
            return task;
          }).toList();
          editingid = null;
          input.clear();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchtasks();
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo'),
        centerTitle: true,
        backgroundColor: Colors.purple.shade100,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: input,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Enter Text",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: clickhandler,
                    child: const Text(
                      "ADD",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.purple.shade100,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text("No Task Added yet."))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        final id = task['_id'];
                        final text = task['text'];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    task['text'],
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ), // Task text fills space
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      input.text = task['text'];
                                      editingid = task['_id'];
                                    });
                                  },
                                  child: const Text(
                                    "Edit",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final success = await deletetask(id);
                                    if (success) {
                                      setState(() {
                                        tasks.removeWhere(
                                          (task) => task['_id'] == id,
                                        );
                                      });
                                    }
                                  },
                                  child: const Text(
                                    "Delete",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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

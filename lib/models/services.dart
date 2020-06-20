
import 'employee_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Services {

  static const ROOT = "http://10.0.2.2:80/employeesdb/employee_actions.php";
  static const _CREATE_TABLE_ACTION = "CREATE_TABLE";
  static const _GET_ALL_ACTION = "GET_ALL";
  static const _ADD_EMP_ACTION = "ADD_EMP";
  static const _UPDATE_EMP_ACTION = "UPDATE_EMP";
  static const _DELETE_EMP_ACTION = "DELETE_EMP";

  //  method to create the table employees
static Future<String> createTable() async {

  try {
    // add the parameter to pass the request
    var map = Map<String, dynamic>();
    map['action'] = _CREATE_TABLE_ACTION;
    final response = await http.post(ROOT, body: map);
    print("Create table response: ${response.body}");
    if(200 == response.statusCode) {
      return response.body.toString();
    } else {
      return "error";
    }

  }catch(e) {
    return "error in creating table \n error: $e";
  }
}


static Future<List<Employee>> getEmployees() async {
  try {
    var map = Map<String, dynamic>();
    map['action'] = _GET_ALL_ACTION;
    final response = await http.post(ROOT, body: map);
    print("Get all employee data : ${response.body}");

    if(200 == response.statusCode) {
      List<Employee> list = parseResponse(response.body);
      return list;
    } else {
      return List<Employee>();
    }

  } catch(e) {
    return List<Employee>();  //  return an empty list on exception/error
  }
}
//  parsed response method
static List<Employee> parseResponse(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Employee>((json) => Employee.fromJson(json)).toList();
}

//  methods to add employee to the table of db
static Future<String> addEmployee(String firstName, String lastName) async {
  try {
    var map = Map<String, dynamic>();
    map['action'] = _ADD_EMP_ACTION;
    map['first_name'] = firstName;
    map['last_name'] = lastName;
    final response = await http.post(ROOT, body: map);
    print("addEmployee response: ${response.body}");
    if(200 == response.statusCode) {
      return response.body;
    } else {
      return "error";
    }
  } catch(e) {
    return "error in addEmployee() \n error: $e";
  }
}


//  methods to update the employee
static Future<String> updateEmployee(String empId, String firstName, String lastName) async {
  try {
    var map = Map<String, dynamic>();
    map['action'] = _UPDATE_EMP_ACTION;
    map['emp_id'] = empId;
    map['first_name'] = firstName;
    map['last_name'] = lastName;

    final response = await http.post(ROOT, body: map);
    print("updateEmployee response: ${response.body}");

    if(200 == response.statusCode) {
      return response.body;
    } else {
      return "error";
    }

  } catch(e) {
    return "error is updateEmployee \n error: $e";
  }
}

//  method to delete data from the database
static Future<String> deleteEmployee(String empId) async {
  try {
    var map = Map<String, dynamic>();
    map['action'] = _DELETE_EMP_ACTION;
    map['emp_id'] = empId;

    final response = await http.post(ROOT, body: map);
    print("deleteEmployee response: ${response.body}");
    if(200 == response.statusCode) {
      return response.body;
    } else {
      return "error";
    }

  } catch(e) {
    return "error in deleteEmployee \n error: $e";
  }
}








}
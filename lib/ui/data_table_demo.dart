
import 'dart:developer';

import 'package:flutter/material.dart';

import '../models/employee_model.dart';
import '../models/services.dart';

class DataTableDemo extends StatefulWidget {
  final String title = "Data table";
  @override
  _DataTableDemoState createState() => _DataTableDemoState();
}

class _DataTableDemoState extends State<DataTableDemo> {

  List<Employee> _employees;
  GlobalKey<ScaffoldState> _scaffoldKey;
  //  controllers
  TextEditingController _firstNameController;
  TextEditingController _lastNameController;
  Employee _selectedEmployee;
  bool _isUpdating;
  String _titleProgress;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _employees = [];
    _isUpdating = false;
    _titleProgress = widget.title;
    _scaffoldKey = new GlobalKey();
    _firstNameController = new TextEditingController();
    _lastNameController = new TextEditingController();
  }

  //  method to update title in the appbar title
  _showProgress(String message) {
    setState(() {
      _titleProgress = message;
    });
  }

  _showSnackBarMessage(context, message) {

    var snackbar = new SnackBar(content: new Text(message));
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  // creating table
  _createTable() {
    try {
      _showProgress('Creating Table...');
      Services.createTable().then((result) {
        if ("success" == result) {
          // Table is created successfully.
          _showSnackBarMessage(context, result);
          _showProgress(widget.title);
        } else {
          debugPrint("ERROR:: Error in here result:- $result");
        }
      });
    } catch(e) {
      debugPrint("ERROR:: $e");
    }
  }

  /*
  * adding values to the database*/
  _addEmployee(){
    if(_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      _showSnackBarMessage(context, "Fields are empty");
      return;
    }
    _showProgress("Add employee");

    Services.addEmployee(_firstNameController.text, _lastNameController.text).then((result){
      if("success" == result) {
        _getEmployees();  //  refresh the list
        _showSnackBarMessage(context, "Data is added");
        _clearValues();
      }
      _clearValues();
    });
  }

  _getEmployees(){
    _showProgress("Loading employee");
    Services.getEmployees().then((employees){
      setState(() {
        _employees = employees;
      });
      _showProgress(widget.title);  //  reset the title
      debugPrint("Length: ${employees.length}");

    });
  }

  _updateEmployee(Employee employee){
    setState(() {
      _isUpdating = true;
    });
    _showProgress("Updating employee");
    Services.updateEmployee(employee.id, _firstNameController.text, _lastNameController.text).then((result){
      if("success" == result) {
        setState(() {
          _isUpdating = false;
        });
        _getEmployees();  //  refresh the list
        _showSnackBarMessage(context, "Data is updated successfully");
      }
      _clearValues();
    });
  }

  _deleteEmployee(Employee employee){
    _showProgress("Delete employee");
    Services.deleteEmployee(employee.id).then((result){
      if("success" == result){
        _showSnackBarMessage(context, "${employee.id} id is deleted successfully.");
        _getEmployees();  //  refresh the list
      }
    });
  }

  //  clear text fields values
  _clearValues() {
    _firstNameController.text = "";
    _lastNameController.text = "";
  }

  _showValues(Employee employee) {
    _firstNameController.text = employee.firstName;
    _lastNameController.text = employee.lastName;
  }

  //  create a Datatable to show all the database values
  SingleChildScrollView _dataBody() {
    return SingleChildScrollView(
      /*
      * both vertical and horizontal scrollView for the datatable to
      * scroll both vertical and horizontal*/
      scrollDirection: Axis.vertical,
      child: new SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: new DataTable(
          //  table columns
          columns: [
            new DataColumn(label: new Text("ID"),),

            new DataColumn(label: new Text("FIRST NAME"),),

            new DataColumn(label: new Text("LAST NAME"),),
          ],

          //  table rows
          rows: _employees.map((employee)=> new DataRow(
            cells: [
              new DataCell(
                  new Text(employee.id),
                  onTap: (){
                    _showValues(employee);
                    _selectedEmployee = employee; //  set the selected employee to update
                    setState(() {
                      _isUpdating = true;
                    });
                  }),

              new DataCell(
                  new Text(employee.firstName.toUpperCase()),
                  onTap: (){
                   _showValues(employee);
                   _selectedEmployee = employee;  //  set the selected employee to update
                    setState(() {
                      _isUpdating = true;
                    });
                  },
              ),

              new DataCell(
                  new Text(employee.lastName.toUpperCase()),
                  onTap: (){
                    _showValues(employee);
                    _selectedEmployee = employee; //  set the selected employee to update
                    setState(() {
                      _isUpdating = true;
                    });
                  },
              ),

            ])
          ).toList(),


        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(_titleProgress),
        centerTitle: true,
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.add),
              onPressed: (){
                _createTable();
                debugPrint("onCreate");
              }),

          new IconButton(
              icon: new Icon(Icons.refresh),
              onPressed: (){
                _getEmployees();
              }),
        ],
      ),

      body: new Container(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.all(20.0),
              child: new TextField(
                controller: _firstNameController,
                decoration: new InputDecoration.collapsed(
                    hintText: "First name",),
              ),
            ),

            new Padding(
              padding: const EdgeInsets.all(20.0),
              child: new TextField(
                controller: _lastNameController,
                decoration: new InputDecoration.collapsed(
                  hintText: "Last name",),
              ),
            ),

            /*
            * add update and cancel button
            * show this button only when updating an employee
            * */
            _isUpdating ?
            new Row(
              children: <Widget>[
                new OutlineButton(
                    child: new Text("UPDATE"),
                    onPressed: (){
                      _updateEmployee(_selectedEmployee);
                    }),

                new OutlineButton(
                    child: new Text("DELETE"),
                    onPressed: (){
                      _deleteEmployee(_selectedEmployee);
                      _clearValues();
                    }),

                new OutlineButton(
                    child: new Text("CANCEL"),
                    onPressed: (){
                      setState(() {
                        _isUpdating = false;
                      });
                      _clearValues();
                    }),
              ],
            )
            : Container(),

            //  showing the table
            new Expanded(
                child: _dataBody()),
          ],
        ),
      ),

      floatingActionButton: new FloatingActionButton(
          onPressed: (){
            //  adding the emplyee
            _addEmployee();
          },
          child: new Icon(Icons.add),
      ),
    );
  }
}

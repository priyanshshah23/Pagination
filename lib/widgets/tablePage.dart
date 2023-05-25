import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geektrust/widgets/tableDataList.dart';
import 'package:geektrust/widgets/tableFooter.dart';
import 'package:http/http.dart' as http;
import '../model/userModel.dart';

class TablePage extends StatefulWidget {
  @override
  _TablePageState createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  final List<UserModel> _tableData = [];
  List<UserModel> _filteredData = [];
  bool _selectAll = false;
  final List<UserModel> _selectedRows = [];
  int _currentPage = 1;
  int _totalPages = 1;
  final int _rowsPerPage = 10;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      var apiUrl = Uri.parse(
          'https://geektrust.s3-ap-southeast-1.amazonaws.com/adminui-problem/members.json');

      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        setState(() {
          _tableData.clear();
          var data = jsonDecode(response.body);
          for (var item in data) {
            _tableData.add(UserModel.fromJson(item));
          }
          _filteredData = List.from(_tableData);
          _updateTotalPages();
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (error) {
      _showErrorDialog('Failed to fetch data. Please try again later.');
    }
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _updateTotalPages() {
    _totalPages = (_filteredData.length / _rowsPerPage).ceil();
  }

  void _filterData(String searchTerm) {
    setState(() {
      if (searchTerm.isEmpty) {
        _filteredData = List.from(_tableData);
      } else {
        _filteredData = _tableData
            .where((row) =>
                row.name!.toLowerCase().contains(searchTerm.toLowerCase()) ||
                row.email!.toLowerCase().contains(searchTerm.toLowerCase()) ||
                row.role!.toLowerCase().contains(searchTerm.toLowerCase()))
            .toList();
      }
      _updateTotalPages();
      _currentPage = 1;
    });
  }

  List<UserModel> _getCurrentPageData() {
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex = startIndex + _rowsPerPage;

    if (_filteredData.length < endIndex) {
      if (_filteredData.length < startIndex) {
        return _filteredData.sublist(0, _filteredData.length);
      }
      return _filteredData.sublist(startIndex, _filteredData.length);
    }
    return _filteredData.sublist(startIndex, endIndex);
  }

  void _deleteRow(UserModel rowData) {
    setState(() {
      _tableData.remove(rowData);
      _filteredData.remove(rowData);
      _selectedRows.remove(rowData);
      _updateTotalPages();
    });
  }

  void _editRow(UserModel rowData) {
    final TextEditingController nameController =
        TextEditingController(text: rowData.name);
    final TextEditingController emailController =
        TextEditingController(text: rowData.email);
    final TextEditingController roleController =
        TextEditingController(text: rowData.role);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  rowData.name = nameController.text;
                  rowData.email = emailController.text;
                  rowData.role = roleController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedRows() {
    setState(() {
      _tableData.removeWhere((row) => _selectedRows.contains(row));
      _filteredData.removeWhere((row) => _selectedRows.contains(row));
      _selectedRows.clear();
      _selectAll = false;
      _updateTotalPages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Data'),
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _filterData(value),
                decoration: const InputDecoration(
                  hintText: 'Search',
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white),
            child: const Padding(
              padding:
              EdgeInsets.only(left: 70, right: 24.0, top: 16, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Name"),
                  Text("Email"),
                  Text("Role"),
                  Text("Actions")
                ],
              ),
            ),
          ),
          TableDataList(
            currentPageData: _getCurrentPageData(),
            deleteRow: _deleteRow,
            editRow: _editRow,
            selectedRows: _selectedRows,
          ),
          TableFooter(
            currentPage: _currentPage,
            totalPages: _totalPages,
            selectAll: _selectAll,
            deleteSelectedRows:
            _selectedRows.isNotEmpty ? _deleteSelectedRows : null,
            goToFirstPage: _currentPage > 1
                ? () {
              setState(() {
                _currentPage = 1;
                _selectAll = _getCurrentPageData()
                    .where((element) => element.selected == true)
                    .length ==
                    _getCurrentPageData().length;
              });
            }
                : null,
            goToLastPage: _currentPage < _totalPages
                ? () {
              setState(() {
                _currentPage = _totalPages;
                _selectAll = _getCurrentPageData()
                    .where((element) => element.selected == true)
                    .length ==
                    _getCurrentPageData().length;
              });
            }
                : null,
            goToNextPage: _currentPage < _totalPages
                ? () {
              setState(() {
                _currentPage++;
                _selectAll = _getCurrentPageData()
                    .where((element) => element.selected == true)
                    .length ==
                    _getCurrentPageData().length;
              });
            }
                : null,
            goToPreviousPage: _currentPage > 1
                ? () {
              setState(() {
                _currentPage--;
                _selectAll = _getCurrentPageData()
                    .where((element) => element.selected == true)
                    .length ==
                    _getCurrentPageData().length;
              });
            }
                : null,
            selectAllChanged: (value) {
              setState(() {
                _selectAll = value!;
                for (final rowData in _getCurrentPageData()) {
                  rowData.selected = value;
                  if (value) {
                    _selectedRows.add(rowData);
                  } else {
                    _selectedRows.remove(rowData);
                  }
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

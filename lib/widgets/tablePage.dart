import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  initState() {
    super.initState();
    fetchData();
  }

  /// update the total pages count
  void _updateTotalPages() {
    _totalPages = (_filteredData.length / _rowsPerPage).ceil();
  }

  /// filter the data based on the search term
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

  /// delete the selected rows
  void _deleteSelectedRows() {
    setState(() {
      _tableData.removeWhere((row) => _selectedRows.contains(row));
      _filteredData.removeWhere((row) => _selectedRows.contains(row));
      _selectedRows.clear();
      _selectAll = false;
      _updateTotalPages();
    });
  }

  /// get the current page data
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

  /// delete the row
  void _deleteRow(UserModel rowData) {
    setState(() {
      _tableData.remove(rowData);
      _filteredData.remove(rowData);
      _selectedRows.remove(rowData);
      _updateTotalPages();
    });
  }

  /// fetch the data from the api
  Future<dynamic> fetchData() async {
    var apiUrl = Uri.parse(
        'https://geektrust.s3-ap-southeast-1.amazonaws.com/adminui-problem/members.json');

    try {
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        setState(() {
          _tableData.clear();
          var data = jsonDecode(response.body ?? '');
          for (var item in data) {
            _tableData.add(UserModel.fromJson(item));
          }
          _filteredData = List.from(_tableData);
          _updateTotalPages();
        });
      } else {
        // Request failed
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // An error occurred
      print('Error: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Data'),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white),
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
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 70, right: 24.0, top: 16, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Name"),
                  Text("Email"),
                  Text("Role"),
                  Text("Actions")
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _getCurrentPageData().length,
              itemBuilder: (context, index) {
                final rowData = _getCurrentPageData()[index];
                return ListTile(
                  tileColor: rowData.selected! ? Colors.grey[300] : null,
                  leading: Checkbox(
                    value: rowData.selected,
                    onChanged: (value) {
                      setState(() {
                        rowData.selected = value!;
                        if (value) {
                          _selectedRows.add(rowData);
                        } else {
                          _selectedRows.remove(rowData);
                        }
                      });
                    },
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 3,
                          child: Text(
                            rowData.name!,
                          )),
                      Expanded(flex: 3, child: Text(rowData.email!)),
                      Expanded(flex: 2, child: Text(rowData.role!)),
                      const Spacer(),
                      InkWell(
                          onTap: () {
                            _editRow(rowData);
                          },
                          child: const Icon(Icons.edit)),
                      const SizedBox(width: 10),
                      InkWell(
                          onTap: () {
                            _deleteRow(rowData);
                          },
                          child: const Icon(Icons.delete))
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
            ),
          ),
          Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _selectAll,
                        onChanged: (value) {
                          setState(() {
                            _selectAll = value!;
                            // _selectedRows.clear();
                            for (final rowData in _getCurrentPageData()) {
                              rowData.selected = value;
                              if (value) {
                                _selectedRows.add(rowData);
                              }
                            }
                          });
                        },
                      ),
                      const Text('Select All'),
                    ],
                  ),
                  ElevatedButton(
                    onPressed:
                        _selectedRows.isNotEmpty ? _deleteSelectedRows : null,
                    child: const Text('Delete Selected'),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() {
                            _currentPage = 1;
                            _selectAll = _getCurrentPageData()
                                    .where(
                                        (element) => element.selected == true)
                                    .length ==
                                _getCurrentPageData().length;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.first_page),
                ),
                IconButton(
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() {
                            _currentPage--;
                            _selectAll = _getCurrentPageData()
                                    .where(
                                        (element) => element.selected == true)
                                    .length ==
                                _getCurrentPageData().length;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('Page $_currentPage of $_totalPages'),
                IconButton(
                  onPressed: _currentPage < _totalPages
                      ? () {
                          setState(() {
                            _currentPage++;
                            _selectAll = _getCurrentPageData()
                                    .where(
                                        (element) => element.selected == true)
                                    .length ==
                                _getCurrentPageData().length;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
                IconButton(
                  onPressed: _currentPage < _totalPages
                      ? () {
                          setState(() {
                            _currentPage = _totalPages;
                            _selectAll = _getCurrentPageData()
                                    .where(
                                        (element) => element.selected == true)
                                    .length ==
                                _getCurrentPageData().length;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.last_page),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

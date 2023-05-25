import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/userModel.dart';

class TableDataList extends StatefulWidget {
  const TableDataList({
    Key? key,
    required this.currentPageData,
    required this.deleteRow,
    required this.editRow,
    required this.selectedRows,
  }) : super(key: key);

  final List<UserModel> currentPageData;
  final Function(UserModel) deleteRow;
  final Function(UserModel) editRow;
  final List<UserModel> selectedRows;

  @override
  State<TableDataList> createState() => _TableDataListState();
}

class _TableDataListState extends State<TableDataList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        itemCount: widget.currentPageData.length,
        itemBuilder: (context, index) {
          final rowData = widget.currentPageData[index];
          return ListTile(
            tileColor: rowData.selected! ? Colors.grey[300] : null,
            leading: Checkbox(
              value: rowData.selected,
              onChanged: (value) {
                setState(() {
                  rowData.selected = value!;
                  if (value) {
                    widget.selectedRows.add(rowData);
                  } else {
                    widget.selectedRows.remove(rowData);
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
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(rowData.email!),
                ),
                Expanded(
                  flex: 2,
                  child: Text(rowData.role!),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    widget.editRow(rowData);
                  },
                  child: const Icon(
                    Icons.edit,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    widget.deleteRow(rowData);
                  },
                  child: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                )
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
      ),
    );
  }
}

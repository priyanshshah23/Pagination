import 'package:flutter/material.dart';

class TableFooter extends StatelessWidget {
  const TableFooter({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.selectAll,
    required this.deleteSelectedRows,
    required this.goToFirstPage,
    required this.goToPreviousPage,
    required this.goToNextPage,
    required this.goToLastPage,
    required this.selectAllChanged,
  }) : super(key: key);

  final int currentPage;
  final int totalPages;
  final bool selectAll;
  final VoidCallback? deleteSelectedRows;
  final VoidCallback? goToFirstPage;
  final VoidCallback? goToPreviousPage;
  final VoidCallback? goToNextPage;
  final VoidCallback? goToLastPage;
  final ValueChanged<bool?> selectAllChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: selectAll,
                  onChanged: selectAllChanged,
                ),
                const Text('Select All'),
                const SizedBox(width: 20),
                if (deleteSelectedRows != null)
                  ElevatedButton.icon(
                    onPressed: deleteSelectedRows,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Selected'),
                  ),
              ],
            ),
            Row(
              children: [
                Text('Page $currentPage of $totalPages'),
                const SizedBox(width: 20),
                IconButton(
                  onPressed: goToFirstPage,
                  icon: const Icon(Icons.first_page),
                ),
                IconButton(
                  onPressed: goToPreviousPage,
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  onPressed: goToNextPage,
                  icon: const Icon(Icons.chevron_right),
                ),
                IconButton(
                  onPressed: goToLastPage,
                  icon: const Icon(Icons.last_page),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

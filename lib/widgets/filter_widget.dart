import 'package:flutter/material.dart';

class FilterWidget extends StatelessWidget {
  final TextEditingController filterController;
  final ValueChanged<String> onFilter;

  const FilterWidget({
    super.key,
    required this.filterController,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: filterController,
        onChanged: onFilter,
        decoration: InputDecoration(
          labelText: 'Cari...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}

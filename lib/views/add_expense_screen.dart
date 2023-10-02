import 'package:flutter/material.dart';

class AddExpensePage extends StatefulWidget {
  final bool isEditing; // Indicates whether it's an edit mode.

  // Pass isEditing as true when editing an expense.
  const AddExpensePage({Key? key, this.isEditing = false}) : super(key: key);

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _selectedCategory = 'Food'; // Default category
  DateTime _selectedDate = DateTime.now(); // Default date

  @override
  void initState() {
    super.initState();
    // Populate fields with existing expense data if editing.
    if (widget.isEditing) {
      // Replace with logic to fetch and populate expense data for editing.
      _descriptionController.text = 'Expense Description'; // Example data.
      _amountController.text = '50.0'; // Example data.
      _selectedCategory = 'Transportation'; // Example data.
      _selectedDate = DateTime(2023, 10, 1); // Example data.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Expense Details',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Expense Description',
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Expense Amount',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                // Implement date picker to select the date.
              },
              child: Row(
                children: [
                  const Text('Expense Date: '),
                  Text(
                    _selectedDate.toString(), // Display the selected date here.
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              items: <String>[
                'Food',
                'Transportation',
                'Entertainment',
                'Other'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Expense Category',
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // Implement logic to upload receipt image (if needed).
              },
              child: const Text('Attach Receipt Image'),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // Implement logic to save or update the expense based on widget.isEditing.
                if (widget.isEditing) {
                  // Update existing expense logic here.
                } else {
                  // Add new expense logic here.
                }
              },
              child: Text(widget.isEditing ? 'Update Expense' : 'Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}

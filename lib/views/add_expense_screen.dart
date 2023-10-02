import 'package:flutter/material.dart';

class AddExpensePage extends StatelessWidget {
  const AddExpensePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
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
            // Expense Name TextField
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Expense Description',
              ),
            ),
            const SizedBox(height: 16.0),
            // Expense Amount TextField
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Expense Amount',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            // Expense Date Selection
            GestureDetector(
              onTap: () {
                // Implement date picker here to allow the user to select the date.
              },
              child: const Row(
                children: [
                  Text('Expense Date: '),
                  Text(
                    'Selected Date', // Display the selected date here.
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            // Expense Category Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Expense Category',
              ),
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
              onChanged: (String? newValue) {
                // Handle category selection.
              },
            ),
            const SizedBox(height: 32.0),
            // Attachment Image Upload (Optional)
            ElevatedButton(
              onPressed: () {
                // Implement logic for uploading receipt image (if needed).
              },
              child: const Text('Attach Receipt Image'),
            ),
            const SizedBox(height: 32.0),
            // Save Button
            ElevatedButton(
              onPressed: () {
                // Implement logic to save the new expense.
              },
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}

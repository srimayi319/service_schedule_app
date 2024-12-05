import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date and time formatting

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  DateTime selectedDate = DateTime.now();
  String? selectedTime;
  final List<String> timeSlots = ['10:00 AM', '12:00 PM', '2:00 PM', '4:00 PM'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Services"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service description and price
            Text(
              'Service: Installation & Maintenance',
              style: Theme.of(context).textTheme.titleLarge, // Updated style
            ),
            SizedBox(height: 8),
            Text(
              'Description: Professional installation and maintenance of water purifiers.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Price: ₹1,000',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Date selection
            Row(
              children: [
                Text(
                  "Select Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                  style: TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Time slot selection
            DropdownButton<String>(
              hint: Text("Select Time Slot"),
              value: selectedTime,
              items: timeSlots.map((time) {
                return DropdownMenuItem<String>(
                  value: time,
                  child: Text(time),
                );
              }).toList(),
              onChanged: (newTime) {
                setState(() {
                  selectedTime = newTime;
                });
              },
            ),
            SizedBox(height: 16),

            // Service Scheduling Button
            ElevatedButton(
              onPressed: () {
                if (selectedTime != null) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Confirm Schedule'),
                      content: Text(
                          'You have selected: \nDate: ${DateFormat('yyyy-MM-dd').format(selectedDate)}\nTime: $selectedTime'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // Schedule the service or handle confirmation logic
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Service Scheduled!'),
                              ),
                            );
                          },
                          child: const Text('Confirm'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select a time slot!'),
                    ),
                  );
                }
              },
              child: Text("Schedule Service"),
            ),
          ],
        ),
      ),
    );
  }
}

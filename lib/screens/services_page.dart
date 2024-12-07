import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ServicePage extends StatefulWidget {
  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  DateTime selectedDate = DateTime.now();
  String? selectedTime;
  String? selectedService;
  String? serviceDocId; // Track the document ID for cancellation

  final List<String> services = ['Installation', 'Maintenance', 'Repair'];
  final List<String> timeSlots = ['10:00 AM', '12:00 PM', '2:00 PM', '4:00 PM'];

  // Function to select a date
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

  // Function to save the service to Firestore
  Future<void> saveServiceToCloud() async {
    try {
      final docRef = await FirebaseFirestore.instance.collection('scheduled_services').add({
        'service': selectedService,
        'date': selectedDate.toIso8601String(),
        'time': selectedTime,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        serviceDocId = docRef.id; // Store the document ID for cancellation
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service Scheduled and Saved!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    }
  }

  // Function to cancel the scheduled service
  Future<void> cancelService() async {
    if (serviceDocId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('scheduled_services')
            .doc(serviceDocId)
            .delete();

        setState(() {
          serviceDocId = null; // Reset the serviceDocId
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service Cancelled!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error canceling service: $e')),
        );
      }
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Selection Dropdown
              Text(
                "Select a Service:",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                hint: const Text("Choose a service"),
                value: selectedService,
                items: services.map((service) {
                  return DropdownMenuItem<String>(
                    value: service,
                    child: Text(service),
                  );
                }).toList(),
                onChanged: (newService) {
                  setState(() {
                    selectedService = newService;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Date Selection
              Row(
                children: [
                  Text(
                    "Select Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Time Slot Selection
              Text(
                "Select a Time Slot:",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                hint: const Text("Choose a time slot"),
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
              const SizedBox(height: 16),

              // Schedule Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedService == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a service!')),
                      );
                    } else if (selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a time slot!')),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Schedule'),
                          content: Text(
                            'You have selected:\n'
                                'Service: $selectedService\n'
                                'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}\n'
                                'Time: $selectedTime',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context); // Close the dialog
                                await saveServiceToCloud(); // Save data to Firestore
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
                    }
                  },
                  child: const Text("Schedule Service"),
                ),
              ),

              // Display scheduled services using StreamBuilder
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('scheduled_services')
                    .orderBy('timestamp', descending: true) // Order by timestamp for latest services
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final servicesList = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: servicesList.length,
                      itemBuilder: (context, index) {
                        final service = servicesList[index];
                        return ListTile(
                          title: Text(service['service']),
                          subtitle: Text(
                            'Scheduled on: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(service['date']))} at ${service['time']}',
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No scheduled services.'));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

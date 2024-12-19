import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreViewer extends StatelessWidget {
  final String collectionName; // The name of the Firestore collection

  const FirestoreViewer({Key? key, required this.collectionName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Viewer: $collectionName'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final data = documents[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text('Document ID: ${documents[index].id}'),
                subtitle: Text(data.toString()), // Display the document data
              );
            },
          );
        },
      ),
    );
  }
}

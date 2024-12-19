import 'package:flutter/material.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Products'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ProductItem(
            imageUrl: 'assets/images/filter1.jpg',  // Replace with your image path
            productName: 'DrinkPrimeRO ',
            description: 'Advanced purification technology for clean water.',
            price: '₹12,999',
          ),
          ProductItem(
            imageUrl: 'assets/images/filter2.jpg',  // Replace with your image path
            productName: 'AquaGrand',
            description: 'Compact design with UV technology.',
            price: '₹8,499',
          ),
          ProductItem(
            imageUrl: 'assets/images/filter2.jpg',  // Replace with your image path
            productName: 'AquaGrand',
            description: 'Compact design with UV technology.',
            price: '₹8,499',
          )
          // Add more ProductItems as needed
        ],
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String description;
  final String price;

  const ProductItem({
    Key? key,
    required this.imageUrl,
    required this.productName,
    required this.description,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imageUrl),  // Display the image
            const SizedBox(height: 8),
            Text(
              productName,
              style: Theme.of(context).textTheme.titleMedium,  // Updated
            ),
            const SizedBox(height: 4),
            Text(description),
            const SizedBox(height: 8),
            Text(price, style: Theme.of(context).textTheme.bodyLarge),  // Updated
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'book.dart'; // Ensure the `Book` model exists here

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final Map<String, int> orderList = {}; // Stores quantities for each book ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          "Cart",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cart').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No data available"));
          }

          // Map Firestore documents to `Book` objects
          final cartList = snapshot.data!.docs.map((doc) {
            return Book(
              img: doc['img'],
              name: doc['name'],
              author: doc['author'],
              discription: doc['discription'],
              price: doc['price'],
              id: doc.id,
            );
          }).toList();

          // Initialize orderList quantities if they are not already set
          for (var item in cartList) {
            orderList.putIfAbsent(item.id!, () => 1);
          }

          // Calculate the total price
          int total = cartList.fold(0, (sum, book) {
            int price = int.tryParse(book.price ?? '0') ?? 0;
            int quantity = orderList[book.id!] ?? 1;
            return sum + (price * quantity);
          });

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartList.length,
                  itemBuilder: (context, index) {
                    final book = cartList[index];
                    final bookId = book.id!;
                    final price = int.tryParse(book.price ?? '0') ?? 0;
                    final quantity = orderList[bookId] ?? 1;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            // Book Image
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: Image.network(
                                book.img ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            ),
                            // Book Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Name: ${book.name}",
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text("Author: ${book.author}"),
                                  Text("Description: ${book.discription}",
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text("Price: \u20b9 $price"),
                                  // Quantity Control
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            if (orderList[bookId]! > 1) {
                                              orderList[bookId] = orderList[bookId]! - 1;
                                            }
                                          });
                                        },
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                      ),
                                      Text("$quantity"),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            orderList[bookId] = orderList[bookId]! + 1;
                                          });
                                        },
                                        icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () {
                                          deleteItem(bookId);
                                        },
                                        icon: const Icon(Icons.delete, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Total Price Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.purple.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total: \u20b9 $total",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                      onPressed: () {
                         checkout(cartList,orderList);
                      },
                      child: const Text("Checkout", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Function to delete an item from Firestore
  Future<void> deleteItem(String id) async {
    await FirebaseFirestore.instance.collection('cart').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item removed")));
  }

  // Function to simulate checkout
Future<void> checkout(List<Book> cartList, Map<String, int> orderList) async {
  final paymentCollection = FirebaseFirestore.instance.collection('payment');
  final String summaryDocId = "summary"; // Use a fixed ID for summary
  
  int overallTotalPrice = 0;
  int productCount = cartList.length;

  // Add or update each product individually
  for (var book in cartList) {
    int quantity = orderList[book.id!] ?? 1;
    int price = int.tryParse(book.price ?? '0') ?? 0;
    int productTotalPrice = price * quantity;

    // Use book ID to avoid duplicating products
    await paymentCollection.doc(book.id).set({
      'img': book.img,
      'name': book.name,
      'author': book.author,
      'description': book.discription,
      'price_per_unit': price,
      'quantity': quantity,
      'total_price': productTotalPrice,
    }, SetOptions(merge: true)); // Merge updates instead of overwriting
    overallTotalPrice += productTotalPrice;
  }

  // Update the summary document
  await paymentCollection.doc(summaryDocId).set({
    'overall_total_price': overallTotalPrice,
    'total_product_count': productCount,
    'timestamp': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  // Feedback
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Checkout updated successfully!")),
  );
}


}

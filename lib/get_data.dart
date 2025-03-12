import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbcured/book.dart';
import 'package:fbcured/home.dart';
import 'package:fbcured/view_books.dart';
import 'package:flutter/material.dart';

class Get extends StatefulWidget{
  const Get({super.key});
  @override
  State<Get>createState()=>_Get();
}


class _Get extends State<Get>{
   @override
  // void initState() {
  //   super.initState();
  //   fetchCartData(); // Fetch cart data when the widget initializes
  // }

  // // Fetch cart data from Firestore
  // void fetchCartData() async {
  //   final snapshot = await FirebaseFirestore.instance.collection('cart').get();
  //   setState(() {
  //     cart = {
  //       for (var doc in snapshot.docs) doc.id: doc.data(),
  //     };
  //   });
  // }
  // List<Book> booklist = [];
  Map<String,dynamic> cart = {};
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("GetData",style: TextStyle(
          color: Colors.white
        ),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){
                 Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Home()));
        }, icon: Icon(Icons.arrow_back)),
        actions: [
          IconButton(onPressed: (){
         
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ViewBooks()));
           
          }, icon: Icon(Icons.keyboard_arrow_right_sharp,color: Colors.black,size: 30,),),
          SizedBox(width: 10,)
        ],
      ),
      body: Column (
        children: [
          Expanded(
            child:StreamBuilder<QuerySnapshot>(
           stream:  FirebaseFirestore.instance.collection("demo").snapshots(),
           builder: (context,snapshot){
              if(snapshot.connectionState == ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator(),);
              }
              if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
                return const Center(
                  child: Text("No data in database"),
                );
              }
               
                  final booklist = snapshot.data!.docs.map((doc){
                  return Book(
                    img: doc['img'],
                    name: doc['name'], 
                    author: doc['author'], 
                    discription: doc['discription'], 
                    price: doc['price'],
                    id:doc.id
                    );
                }).toList();
                
              return ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: booklist.length,
                itemBuilder: (context,index){
                  final book = booklist[index];
                  final isCreate = cart.containsKey(book.id);
                  return Padding(padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                  child:Container(
                    decoration: BoxDecoration(
                     color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0, 0),
                          blurRadius: 1,
                          spreadRadius: 1,
                        
                        )
                      ]

                    ),
                    child: Column(
                      children: [
                        Row(
                          children :[
                            Padding(padding: EdgeInsets.only(top: 10),
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Image.network(book.img ?? "Not image is fetch "),
                            ),
                            ),
                            Expanded(child: 
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Author name : ${book.author}"),
                                 SizedBox(height: 5,),
                                Text("Book name : ${book.name}"),
                                 SizedBox(height: 5,),
                                Text("Description : ${book.discription}",maxLines: 1,overflow: TextOverflow.ellipsis,),
                                 SizedBox(height: 5,),
                                Text("Price : \u{20B9}${book.price}"),
                              ],
                            )
                            )
                          ]
                        ),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: 100,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10)
                              ),
                              alignment: Alignment.center,
                              child: GestureDetector(onTap: (){
                                showdilohBox(context, book);
                              }, child:Text("Edit",style: TextStyle(
                                color: Colors.white
                              ),),),
                            ),
                             Container(
                              width: 100,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10)
                              ),
                              alignment: Alignment.center,
                              child:GestureDetector(onTap: (){
                                setState(() {
                                  FirebaseFirestore.instance.collection('demo').doc(book.id).delete();
                                });
                              }, child:Text("Remove",style: TextStyle(
                                color: Colors.white
                              ),),),
                            )
                          ],
                        ),
                        SizedBox(height: 5,)
                      ],
                    ),
                  ) ,
                  );
              });
           }) )
        ],
      ),
    );
  }
   void showdilohBox(BuildContext context,Book book){
    final imgController = TextEditingController(text: book.img);
    final nameController = TextEditingController(text: book.name);
    final authorController = TextEditingController(text: book.author);
    final disController = TextEditingController(text: book.discription);
    final priceController = TextEditingController(text: book.price);

    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: const Text("update dialogBox"),
        content: SingleChildScrollView(
          child: Column(
            children: [
               TextField(
                controller: imgController,
                decoration: InputDecoration(
                  labelText: 'img'
                ),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'name'
                ),
              ),
               TextField(
                controller: authorController,
                decoration: InputDecoration(
                  labelText: 'author'
                ),
              ),
               TextField(
                controller: disController,
                decoration: InputDecoration(
                  labelText: 'discription'
                ),
              ),
               TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'price'
                ),
              ),
              
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () =>Navigator.of(context).pop(), 
          child: const Text("cancle"),
          ),
          ElevatedButton(onPressed:(){
             _updatebook(
             imgController.text,
             nameController.text,
             authorController.text,
             disController.text,
             priceController.text,
             book);
             Navigator.of(context).pop();
             }, 
             child: const Text("Update")
             )
          
        ],
      );
    });
    }
     Future<void> _updatebook(String img,String name, String author, String discription, String price, Book book) async {
    await FirebaseFirestore.instance.collection('demo').doc(book.id).update({
      'img': img,
      'name': name,
      'author': author,
      'discription': discription,
      'price': price,
    });
    // Update cart if the book is in the cart
    // final cartDoc = await FirebaseFirestore.instance.collection('cart').doc(book.id).get();
    // if (cartDoc.exists) {
    //   await FirebaseFirestore.instance.collection('cart').doc(book.id).update({
    //     'img':img,
    //     'name': name,
    //     'author': author,
    //     'discription': discription,
    //     'price': price,
    //   });
    // }
  }
  // Future<void> addcart(Book book)async{

  //   try{
  //      await FirebaseFirestore.instance.collection("cart").doc(book.id).set({
  //       'img':book.img,
  //       'name':book.name,
  //       'author':book.author,
  //       'discription':book.discription,
  //       'price':book.price,
  //       'id':book.id
  //     });
  //     fetchCartData();
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("add data")));
  //     }
  //   catch (e){
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("issue adding the cart")));
  //   }
  //   }
  //   Future<void> remove(var id)async{
  //     await FirebaseFirestore.instance.collection("cart").doc(id).delete();
  //     fetchCartData();
  //   }
}
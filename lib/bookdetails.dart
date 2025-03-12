import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbcured/book.dart';
import 'package:flutter/material.dart';

class Bookdetails extends StatefulWidget{
  List<Book> bookdetails = [];
 final int index;
  Bookdetails({super.key, required this.bookdetails, required this.index});
  
  @override
  // ignore: no_logic_in_create_state
  State<Bookdetails>createState() => _Bookdetails();
}
class _Bookdetails extends State<Bookdetails>{
  Map<String,dynamic> cart = {};
    @override
  void initState() {
    super.initState();
    loadCart(); // Load the initial cart data
  }

  // Load cart data from Firestore
  Future<void> loadCart() async {
    final cartData = await FirebaseFirestore.instance.collection('cart').get();
    setState(() {
      cart = {for (var doc in cartData.docs) doc.id: doc.data()};
    });
  }
  @override
 Widget build(BuildContext context){
  final books = widget.bookdetails[widget.index];
  final isCart = cart.containsKey(books.id) ;
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.purple,
      title: Text("Book Details",style: TextStyle(
        color: Colors.white
      ),),
      centerTitle: true,
      automaticallyImplyLeading: true,
    ),
    body: SingleChildScrollView(
    child:Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10,),
        SizedBox(
          width: 400,
          height: 400,
          child: Image.network(widget.bookdetails[widget.index].img ?? ''),
        ),
       Row(
        children: [
          Padding(padding: EdgeInsets.only(left: 10),
          child: Text("Author : ",style: TextStyle(
          fontSize: 20,   
        ),),
          ),
           Padding(padding: EdgeInsets.only(left: 5,top: 5),
        child: Text(widget.bookdetails[widget.index].author ?? '',style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        ),),
        ),
        ],
       ),
        Row(
        children: [
          Padding(padding: EdgeInsets.only(left: 10),
          child: Text("Name : ",style: TextStyle(
          fontSize: 20, 
        ),),
          ),
           Padding(padding: EdgeInsets.only(left: 5,top: 5),
        child: Text(widget.bookdetails[widget.index].name ?? '',style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        ),),
        ),
        ],
       ),
       SizedBox(height: 10,),
          Row(
        children: [
          Padding(padding: EdgeInsets.only(left: 10),
          child: Text("Description : ",style: TextStyle(
          fontSize: 20, 
        ),),
          ),
          Flexible(
            child: Padding(padding: EdgeInsets.only(left: 5,top: 5),
        child: Text(widget.bookdetails[widget.index].discription ?? '',maxLines: 2,overflow: TextOverflow.ellipsis,style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold
        ),),
        ), )
        ],
       ),
        Row(
        children: [
          Padding(padding: EdgeInsets.only(left: 10),
          child: Text("Price : ",style: TextStyle(
          fontSize: 20, 
        ),),
          ),
           Padding(padding: EdgeInsets.only(left: 5,top: 5),
        child: Text('\u{20B9} ${widget.bookdetails[widget.index].price}',style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        ),),
        ),
        ],
       ),
      ],
    ) ,
  ),
  persistentFooterButtons: [
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [ 
    GestureDetector(onTap: ()async{
      if(!isCart){
        await addtocart(widget.bookdetails[widget.index]);
      }else{
       await remove(widget.bookdetails[widget.index].id);
      }
    },
    child:  Container(
      width: 200,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        (isCart)? 'Remove Data':'Add to Cart',style: TextStyle(color: Colors.white,fontSize: 20),),
    ),
    )
      ],
    ),
  ],
  );
 }
 Future<void> addtocart(Book book)async{
    await  FirebaseFirestore.instance.collection('cart').doc(book.id).set({
        'img':book.img,
        'name':book.name,
        'author':book.author,
        'discription':book.discription,
        'price':book.price,
      });
      loadCart();
 }
 Future<void> remove(var id)async{
  await FirebaseFirestore.instance.collection('cart').doc(id).delete();
 loadCart();
 }
}
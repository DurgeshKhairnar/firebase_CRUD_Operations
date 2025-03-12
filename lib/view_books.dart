import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbcured/book.dart';
import 'package:fbcured/bookdetails.dart';
import 'package:fbcured/cart.dart';
import 'package:fbcured/like.dart';
import 'package:flutter/material.dart';

class ViewBooks extends StatefulWidget{
  const ViewBooks({super.key});
  @override
  State<ViewBooks> createState() => _ViewBooks();
}

class _ViewBooks extends State<ViewBooks>{
   Map<String,dynamic> fav = {};
   @override
   void initState(){
    super.initState();
    favrite();
   }
  Future<void> favrite() async{
    final favdata= await FirebaseFirestore.instance.collection('fav').get();
    setState(() {
      fav ={
        for(var doc in favdata.docs)doc.id: doc.data()
      }; 
    });
  }
 
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Books",style: TextStyle(
          color: Colors.white
        ),),
        backgroundColor: Colors.purple,
        centerTitle: true,
        automaticallyImplyLeading: true,
      
      ),
      body:StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('demo').snapshots(),
        builder: (context,snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }
          if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
            return Center(child: Text("Books are not Available"),);
          }
            final bookslist = snapshot.data!.docs.map((docs){
                return Book(
                  img: docs['img'], 
                  name: docs['name'], 
                  author: docs['author'], 
                  discription: docs['discription'], 
                  price:docs['price'] ,
                  id: docs.id
                  );
            }).toList();
          return GridView.builder(
            itemCount: bookslist.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,
               mainAxisSpacing:0,
               crossAxisSpacing:20,
               childAspectRatio: 2/ 3.40,
             ) ,
           itemBuilder: (context,index){
            final books = bookslist[index];
            final isfav = fav.containsKey(books.id);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal:10,vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black
                  ),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 0),
                      spreadRadius: 1,
                      blurRadius: 1,
                      color: Colors.grey
                    )
                  ],
                  borderRadius:BorderRadius.circular(10) 
                ),
                child:GestureDetector(onTap: (){
                  setState(() async{
                   await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Bookdetails(bookdetails:bookslist,index:index,)));
                  });
                  favrite();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  SizedBox(
                  width: 200,
                  height: 200,
                  child:Image.network(books.img ?? ""),
                 ),
                  Row(children: [
                    Padding(padding: EdgeInsets.only(left: 5),
                 child:  Text(books.author ?? '',),
                 ),
                 SizedBox(width: 30,),
                 GestureDetector(onTap: ()async{
                  if(!isfav){
                    await addfav(books);
                  }else{
                    await removefav(books.id);
                  }
                 },
                 child:(isfav)?
                  Icon(Icons.favorite,size: 30,color: Colors.red,)
                  :Icon(Icons.favorite_border,size: 30,),
                 ),
                  ],),
                 Padding(padding: EdgeInsets.only(left: 5),
                 child:  Text(books.name ?? '',style: TextStyle(fontWeight:FontWeight.bold),),
                 ),
                   Padding(padding: EdgeInsets.only(left: 5),
                 child:  Text(books.discription ?? '',maxLines: 1,overflow:TextOverflow.ellipsis,),
                 ),
                  Padding(padding: EdgeInsets.only(left: 5),
                 child:  Text("\u{20B9}${books.price}"),
                 )
                  ],
                ),
                )
              ),
            );
           });
        }),
        persistentFooterButtons: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                 IconButton(onPressed: (){
                  setState(() {});
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Like()));
                  favrite();
                 }, icon: Icon(Icons.favorite,size: 40,)),
                  IconButton(onPressed: (){
                   setState(() {});
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Cart()));
                  favrite();
                 }, icon: Icon(Icons.add_shopping_cart,size: 40,))
              ],
            )
        ],
    );
  }
  Future<void>addfav(Book book)async{
    await FirebaseFirestore.instance.collection('fav').doc(book.id).set({
      'img':book.img,
      'name':book.name,
      'author':book.author,
      'discription':book.discription,
      'price':book.price,
    });
    favrite();
  }
  Future<void>removefav(var id)async {
    await FirebaseFirestore.instance.collection('fav').doc(id).delete();
   favrite();
  }
}
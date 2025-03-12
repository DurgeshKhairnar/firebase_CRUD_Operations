import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbcured/book.dart';
import 'package:flutter/material.dart';

class Like extends StatefulWidget{
  const Like({super.key});
  @override
  State<Like>createState()=>_Like();
}
class _Like extends State<Like>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text("Favorites",style: TextStyle(
          color: Colors.white
        ),),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('fav').snapshots(), 
        builder: (context,snapshots){
          if(snapshots.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          }
          if(!snapshots.hasData || snapshots.data!.docs.isEmpty){
            return const Center( child: Text("not add to Favorite"));
          }
      
          final favlist = snapshots.data!.docs.map((doc){
            return Book(
              img: doc['img'], 
              name: doc['name'], 
              author: doc['author'], 
              discription: doc['discription'], 
              price: doc['price'], 
              id: doc.id);
          }).toList();
          return ListView.builder(
            itemCount: favlist.length,
            itemBuilder: (context,index){
            final favdata = favlist[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                   boxShadow:[
                    BoxShadow(
                      offset: Offset(0, 1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      color: Colors.grey
                    )
                   ]
                  ),
                  child: Row(
                    children: [
                     Padding(padding: EdgeInsets.all(5),
                     child: SizedBox(
                      width: 100,
                      height: 100,
                      child:Image.network(favdata.img ?? ''),
                     ),
                     ),
                     Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 5,
                      children: [
                          Text('Name : ${favdata.name}'),
                          Text('Author :${favdata.author}'),
                          Text('Description : ${favdata.discription}'),
                          Row(
                            children: [
                              Text('Price : \u20b9 ${favdata.price}'),
                              SizedBox(width: 30,),
                                IconButton(onPressed: (){
                                 removeFav(favdata.id);
                                }, icon:Icon(Icons.delete) ),
                                 SizedBox(width: 20,),
                                IconButton(onPressed: (){
                                 addtoCart(favdata);
                                }, icon:Icon(Icons.add_shopping_cart) )
                            ],
                          )
                      ],
                     ))
                    ],
                  ),
                ));
            });
        }),
    );
  }
  Future<void>addtoCart(Book data)async{
    await FirebaseFirestore.instance.collection('cart').doc(data.id).set({
      'img':data.img,
      'name':data.name,
      'author':data.author,
      'discription':data.discription,
      'price':data.price
    });
   
  }
 Future <void> removeFav(var id)async{
   await FirebaseFirestore.instance.collection('fav').doc(id).delete();
   
  }
}
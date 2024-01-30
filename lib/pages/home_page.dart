import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todolist/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //firestore
  final FirestoreServices firestoreService = FirestoreServices();
  //text controller
  final TextEditingController texController = TextEditingController();
  //abre el la caja de dialogo para agregar una nueva nota
  void openNoteBox({String? docID}){
    showDialog(context: context,
      builder: (context) => AlertDialog(
        //ingresar texto usuario
      content: TextField(
        controller: texController,
      ),
        actions: [
          //buttoon save
          ElevatedButton(
              onPressed: (){
                //agrega una neuva nota
                if(docID ==null){
                  firestoreService.addNote(texController.text);
                }
                //update una nota existente
                else{
                  firestoreService.updateNote(docID, texController.text);
                }
                //limpiar el texto controller
                texController.clear();

                //cerrar la caja
                Navigator.pop(context);
              },
              child: Text("Agregar"))
        ],
    ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notas"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>( //esta funcion va a ser paa mostrar lo que hay en la base de ddatos
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot){
          //si tenemos datos, trae todos los datos
          if(snapshot.hasData){
            List notesList = snapshot.data!.docs;

            //muestra la lista
            return ListView.builder(
              itemCount: notesList.length,
                itemBuilder: (context, index){
                  //obtener cada documento individual
                    DocumentSnapshot document = notesList[index];
                    String docID = document.id;
                  //obtener nota de cada doc
                  Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
                  String noteText = data['note'];
                    // Obtener timestamp si existe
                    String noteTimestamp = (data['timestamp'] as Timestamp).toDate().toString();
                  //mostrar como título de una lista
                  return ListTile(
                    title: Text(noteText),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //update button
                        IconButton(
                          onPressed: ()=> openNoteBox(docID: docID),
                          icon: const Icon(Icons.settings),
                        ),

                        //delete button
                        IconButton(
                            onPressed: () => firestoreService.deleteNote(docID), 
                            icon: const Icon(Icons.delete))
                      ],
                    ),
                    subtitle: Text(noteTimestamp),
                  );
                },
                );
          }
          //if there is no data return
          else{
            return const Text("No notes..");
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/note.dart';
import 'package:flutter_application_1/models/note_database.dart';
//import 'package:isar/isar.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage>{

  //taxt controller
  final textController = TextEditingController();

  @override
  void initState(){
    super.initState();

    readNotes();
  }

  //create
  void createNote () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          //create button
          MaterialButton(
            onPressed: (){
              //db追加
              context.read<NoteDatabase>().addNote(textController.text);

              //clear controller
              textController.clear();

              //popdialog box
              Navigator.pop(context);
            },
            child: const Text("追加"),
          )
        ],
      ),
    );
  }

  //read
  void readNotes(){
    context.read<NoteDatabase>().fetchNotes();
  }

  //update
  void updateNote(Note note){
    textController.text = note.text;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Note'),
        content: TextField(controller: textController),
        actions: [
          //Update button
          MaterialButton(
            onPressed: () {
              //update note
              context
                  .read<NoteDatabase>()
                  .updateNote(note.pasword, textController.text);
              // clear controlle
              textController.clear();
              //pop dialog box
              Navigator.pop(context);
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }

  //delete
  void deleteNote(int id){
    context.read<NoteDatabase>().deleteNote(id);
  }

  @override
  Widget build(BuildContext context){

    //note db
    final noteDatabase = context.watch<NoteDatabase>();

    //current
    List<Note> currentNotes = noteDatabase.currentNotes;


    return Scaffold(
      appBar: AppBar(title: Text('ノート')),
      floatingActionButton: FloatingActionButton(
        onPressed: createNote,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: currentNotes.length,
        itemBuilder: (context, index){
             //get individual
             final note = currentNotes[index];

             //list  tile UI
             return ListTile(
              title: Text(note.text),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //edit button
                  IconButton(
                    onPressed: () => updateNote(note),
                   icon: const Icon(Icons.edit),
                  ),
                  //delete button
                  IconButton(
                    onPressed: () => deleteNote(note.pasword),
                   icon: const Icon(Icons.delete),
                  ),
                ],
              ),
             );
        },
      ),
    );
  }
}
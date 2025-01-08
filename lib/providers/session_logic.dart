import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // has the DateFormat class

import '../databases/notes.dart';
import '../models/note.dart';

class ProviderSessionLogic with ChangeNotifier {
  List<Note> notesList = [];
  int selectedNoteId = -1;
  TextEditingController textEditingController = TextEditingController();
  String strokesJson = '';

  bool isKeyboardMode = true;

  prepTextAndStrokes() {
    Note selectedNote = getNoteFromId(selectedNoteId);
    textEditingController.text = selectedNote.text;
    strokesJson = selectedNote.scribbles;
  }

  createNote() async {
    // reset on-screen values:
    textEditingController.text = '';
    strokesJson = '';
    notifyListeners();

    // create a note to save to the database:
    Note newNote = Note(
      id: -1,
      dateCreated: getDate(),
      dateModified: getDate(),
      text: '',
      scribbles: '',
    );

    // save to DB and get an ID for the note:
    selectedNoteId = await DbNotes.createNote(newNote);
  }

  updateDb() async {
    Note selectedNote = getNoteFromId(selectedNoteId);

    Note updatedNote = Note(
      id: selectedNoteId,
      dateCreated: selectedNote.dateCreated,
      dateModified: getDate(),
      text: textEditingController.text,
      scribbles: strokesJson,
    );

    await DbNotes.updateNote(updatedNote);
    // ensure the data is updated every time we make a change
    getNotesList();
  }

  getNotesList() async {
    notesList = await DbNotes.getNotesList();
    notifyListeners();
  }

  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////

  Note getNoteFromId(int id) {
    int noteIndex = notesList.indexWhere((note) => note.id == id);
    if (noteIndex < 0) return Note(id: -1, dateCreated: '', dateModified: '', text: 'ERR - NO SUCH ID', scribbles: '');
    return notesList[noteIndex];
  }

  String getDate() {
    var now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }
}

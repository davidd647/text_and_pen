import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // has the DateFormat class

import '../databases/notes.dart';
import '../models/note.dart';
import '../screens/session.dart';

final placeholderNote = Note(
  id: -1,
  dateCreated: '',
  dateModified: '',
  text: 'ERR - NO SUCH ID',
  scribbles: '',
  scribblePreview: '',
  scribblePreviewStrokes: deserializeStrokes(''),
);

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

  deleteById(int id) async {
    await DbNotes.deleteNote(id);
    getNotesList();
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
      scribblePreview: '',
      scribblePreviewStrokes: deserializeStrokes(''),
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
      scribblePreview: selectedNote.scribblePreview,
      scribblePreviewStrokes: deserializeStrokes(selectedNote.scribblePreview),
    );

    await DbNotes.updateNote(updatedNote);
    // ensure the data is updated every time we make a change
    getNotesList();
  }

  updateDbNoteById(int id) async {
    Note selectedNote = getNoteFromId(id);

    Note updatedNote = Note(
      id: selectedNote.id,
      dateCreated: selectedNote.dateCreated,
      dateModified: getDate(),
      text: selectedNote.text,
      scribbles: selectedNote.scribbles,
      scribblePreview: selectedNote.scribblePreview,
      scribblePreviewStrokes: deserializeStrokes(selectedNote.scribblePreview),
    );

    await DbNotes.updateNote(updatedNote);
    getNotesList();
    notifyListeners();
  }

  getNotesList() async {
    notesList = await DbNotes.getNotesList();
    notifyListeners();
  }

  clearCurrentPreview() async {
    Note tmpNote = getNoteFromId(selectedNoteId);
    int selectedIndex = getNoteIndexFromId(tmpNote.id);

    notesList[selectedIndex].scribblePreviewStrokes = [];
    notesList[selectedIndex].scribblePreview = serializeStrokes([]);

    // UPDATE DB WHEN SCRIBBLE IS DONE
    // updateDb();
    await updateDbNoteById(tmpNote.id);
    notifyListeners();
  }

  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////

  Note getNoteFromId(int id) {
    int noteIndex = notesList.indexWhere((note) => note.id == id);
    if (noteIndex < 0) return placeholderNote;

    return notesList[noteIndex];
  }

  int getNoteIndexFromId(int id) {
    return notesList.indexWhere((note) => note.id == id);
  }

  String getDate() {
    var now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/session_logic.dart';
import '../screens/session.dart';
import '../models/note.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  static const routeName = '/home';

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late ProviderSessionLogic providerSessionLogic;

  Future<void> addNote() async {
    // create a new note with today's date (today modified, today created)
    await providerSessionLogic.createNote();
    providerSessionLogic.getNotesList();

    // navigate to the note screen
    Navigator.of(context).pushNamed(Session.routeName);
  }

  @override
  void initState() {
    super.initState();

    providerSessionLogic = Provider.of<ProviderSessionLogic>(context, listen: false);
    providerSessionLogic.getNotesList();
  }

  void navToNote(Note note) {
    providerSessionLogic.selectedNoteId = note.id;
    providerSessionLogic.prepTextAndStrokes();
    Navigator.of(context).pushNamed(Session.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final providerSessionLogic = Provider.of<ProviderSessionLogic>(context);
    final double fullWidth = MediaQuery.of(context).size.width;
    final sortedNotes = List<Note>.from(providerSessionLogic.notesList)
      ..sort((a, b) => a.dateModified.compareTo(b.dateModified));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Text and Pen'),
      ),
      body: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            ...sortedNotes.map((note) {
              String title = 'no text';
              if (note.text.isNotEmpty) title = note.text.split('\n')[0];
              return SavedNote(
                onTap: () {
                  navToNote(note);
                },
                title: title,
                dateCreated: note.dateCreated,
                dateModified: note.dateModified,
                width: fullWidth / 2,
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: addNote,
        tooltip: 'Add New Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SavedNote extends StatelessWidget {
  const SavedNote({
    super.key,
    required this.onTap,
    required this.title,
    required this.dateCreated,
    required this.dateModified,
    required this.width,
  });

  final Function onTap;
  final String title;
  final String dateCreated;
  final String dateModified;
  final double width;

  final yDimension = 150.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: SizedBox(
        width: width,
        child: Row(
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: Material(
                color: Colors.grey[200],
                child: InkWell(
                  onTap: () {
                    onTap();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: yDimension,
                    padding: EdgeInsets.all(25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Title: $title',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 21,
                                ),
                              ),
                            ),
                            SizedBox(width: 42),
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'Updated: $dateModified',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.grey[100],
              alignment: Alignment.center,
              width: yDimension,
              height: yDimension,
              child: Icon(
                Icons.brush,
                color: Colors.grey[300],
                size: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:bnotes/layout/adaptive.dart';
import 'package:bnotes/widgets/textbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:bnotes/helpers/database_helper.dart';
import 'package:bnotes/models/notes_model.dart';
import 'package:bnotes/helpers/storage.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  SharedPreferences sharedPreferences;
  bool isAppLogged = false;
  String userFullname = "";
  String userId = "";
  String userEmail = "";
  Storage storage = new Storage();
  String backupPath = "";
  bool isTileView = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  StreamController<List<Notes>> _notesController;
  final dbHelper = DatabaseHelper.instance;
  var uuid = Uuid();
  TextEditingController _noteTitleController = new TextEditingController();
  TextEditingController _noteTextController = new TextEditingController();
  String currentEditingNoteId = "";
  TextEditingController _searchController = new TextEditingController();

  getPref() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      isTileView = sharedPreferences.getBool("is_tile");
      if (isTileView == null) {
        isTileView = false;
      }
    });
  }

  loadNotes() async {
    final allRows = await dbHelper.getNotesAll(_searchController.text);
    _notesController.add(allRows);
  }

  void _saveNote() async {
    if (currentEditingNoteId.isEmpty) {
      await dbHelper
          .insertNotes(new Notes(uuid.v1(), DateTime.now().toString(),
              _noteTitleController.text, _noteTextController.text, '', 0, 0))
          .then((value) {
        loadNotes();
      });
    } else {
      await dbHelper
          .updateNotes(new Notes(
              currentEditingNoteId,
              DateTime.now().toString(),
              _noteTitleController.text,
              _noteTextController.text,
              '',
              0,
              0))
          .then((value) {
        loadNotes();
      });
    }
  }

  void _updateColor(String noteId, int noteColor) async {
    await dbHelper.updateNoteColor(noteId, noteColor).then((value) {
      loadNotes();
    });
  }

  void _deleteNote() async {
    await dbHelper.deleteNotes(currentEditingNoteId).then((value) {
      loadNotes();
    });
  }

  @override
  void initState() {
    getPref();
    _notesController = new StreamController<List<Notes>>();
    loadNotes();
    super.initState();
  }

  void _onSearch() {
    loadNotes();
  }

  void _onClearSearch() {
    setState(() {
      _searchController.text = "";
      loadNotes();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    return Scaffold(
      floatingActionButton: TextBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      body: Padding(
        padding: isDesktop
            ? const EdgeInsets.symmetric(horizontal: 72, vertical: 48)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          padding: EdgeInsets.all(3.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: StreamBuilder<List<Notes>>(
                  stream: _notesController.stream,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Notes>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text(snapshot.error);
                    }
                    if (snapshot.hasData) {
                      if (isTileView)
                        return GridView.count(
                          mainAxisSpacing: 3.0,
                          crossAxisCount: 2,
                          children:
                              List.generate(snapshot.data.length, (index) {
                            var note = snapshot.data[index];
                            return InkWell(
                              // onTap: () {
                              //   _showNoteReader(context, note);
                              // },
                              // onLongPress: () {
                              //   _showOptionsSheet(context, note);
                              // },
                              child: Card(
                                // color: NoteColor.getColor(note.noteColor ?? 0),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          note.noteTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.black),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            note.noteText,
                                            maxLines: 6,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.black38),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                child: Text(
                                              note.noteLabel,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 12.0),
                                            )),
                                            Text(
                                              formatDateTime(note.noteDate),
                                              style: TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 12.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      else
                        return ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            var note = snapshot.data[index];
                            return InkWell(
                              // onTap: () => _showNoteReader(context, note),
                              // onLongPress: () => _showOptionsSheet(context, note),
                              child: Container(
                                margin: EdgeInsets.all(5.0),
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    // color:
                                    // NoteColor.getColor(note.noteColor ?? 0),
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 1.0,
                                          offset: new Offset(1, 1)),
                                    ]),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Text(
                                        note.noteTitle,
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Text(
                                        note.noteText,
                                        style: TextStyle(color: Colors.black38),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.centerRight,
                                      padding: EdgeInsets.all(5.0),
                                      child: Text(
                                        formatDateTime(note.noteDate),
                                        style: TextStyle(
                                            color: Colors.black38,
                                            fontSize: 12.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                    } else {
                      return Center(
                        child: Text('No notes yet!'),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _showDialog() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('New Notes'),
            content: Column(
              children: [],
            ),
          );
        });
  }

  String getDateString() {
    var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime dt = DateTime.now();
    return formatter.format(dt);
  }

  String formatDateTime(String dateTime) {
    var formatter = new DateFormat('MMM dd, yyyy');
    var formatter2 = new DateFormat('hh:mm a');
    DateTime dt = DateTime.parse(dateTime);
    if (dt.day == DateTime.now().day)
      return formatter2.format(dt);
    else
      return formatter.format(dt);
  }
}

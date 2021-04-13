import 'package:bnotes/models/labels_model.dart';
import 'package:bnotes/models/notes_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = 'bnotes.s3db';
  static final _databaseVersion = 1;
  static Database _database;

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (Database db, int version) async {
        await db.execute(
            '''CREATE TABLE notes (note_id text primary key, note_date text, note_title text, note_text text, note_label text, note_archived integer, note_color integer) ''');
        await db.execute(
            '''CREATE TABLE labels (label_id text primary key, label_name text)''');
      },
    );
  }

  Future<List<Notes>> getNotesAll(String filter) async {
    Database db = await instance.database;
    var parsed = await db.query('notes',
        orderBy: 'note_date DESC',
        where: filter.isNotEmpty
            ? 'note_title LIKE \'%' +
            filter +
            '%\' OR note_text LIKE \'%' +
            filter +
            '%\''
            : '(1=1)');
    return parsed.map<Notes>((json) => Notes.fromJson(json)).toList();
  }

  Future<bool> insertNotes(Notes note) async {
    Database db = await instance.database;
    int id = await db.insert('notes', note.toJson());
    return true;
  }

  Future<bool> updateNotes(Notes note) async {
    Database db = await instance.database;
    Map<String, dynamic> map = {
      'note_id': note.noteId,
      'note_date': note.noteDate,
      'note_title': note.noteTitle,
      'note_text': note.noteText
    };
    String _id = map['note_id'];
    final rowsAffected =
    await db.update('notes', map, where: 'note_id = ?', whereArgs: [_id]);
    return (rowsAffected == 1);
  }

  Future<bool> updateNoteColor(String noteId, int noteColor) async {
    Database db = await instance.database;
    Map<String, dynamic> map = {'note_id': noteId, 'note_color': noteColor};
    String _id = map['note_id'];
    final rowsAffected =
    await db.update('notes', map, where: 'note_id = ?', whereArgs: [_id]);
    return (rowsAffected == 1);
  }

  Future<bool> updateNoteLabel(String noteId, String noteLabel) async {
    Database db = await instance.database;
    Map<String, dynamic> map = {'note_id': noteId, 'note_label': noteLabel};
    String _id = map['note_id'];
    final rowsAffected =
    await db.update('notes', map, where: 'note_id = ?', whereArgs: [_id]);
    return (rowsAffected == 1);
  }

  Future<bool> deleteNotes(String noteId) async {
    Database db = await instance.database;
    int rowsAffected =
    await db.delete('notes', where: 'note_id = ?', whereArgs: [noteId]);
    return (rowsAffected == 1);
  }

  Future<bool> deleteNotesAll() async {
    Database db = await instance.database;
    int rowsAffected = await db.delete('notes');
    return (rowsAffected >= 0);
  }

  Future<List<Labels>> getLabelsAll() async {
    Database db = await instance.database;
    var parsed = await db.query('labels', orderBy: 'label_name');
    print(parsed);
    return parsed.map<Labels>((json) => Labels.fromJson(json)).toList();
  }

  Future<bool> insertLabel(Labels label) async {
    Database db = await instance.database;
    int rowsAffected = await db.insert('labels', label.toJson());
    return (rowsAffected >= 0);
  }

  Future<bool> updateLabel(Labels label) async {
    Database db = await instance.database;
    Map<String, dynamic> map = {
      'label_id': label.labelId,
      'label_name': label.labelName
    };
    String _id = map['label_id'];
    final rowsAffected =
    await db.update('labels', map, where: 'label_id = ?', whereArgs: [_id]);
    return (rowsAffected == 1);
  }

  Future<bool> deleteLabel(String labelId) async {
    Database db = await instance.database;
    int rowsAffected =
    await db.delete('labels', where: 'label_id = ?', whereArgs: [labelId]);
    return (rowsAffected == 1);
  }
}
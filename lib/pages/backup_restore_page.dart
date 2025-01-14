import 'package:bnotes/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:bnotes/helpers/database_helper.dart';
import 'package:bnotes/helpers/storage.dart';
import 'package:bnotes/models/notes_model.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'package:universal_platform/universal_platform.dart';

class BackupRestorePage extends StatefulWidget {
  BackupRestorePage({
    Key? key,
  }) : super(key: BackupRestorePage.staticGlobalKey);

  static final GlobalKey<_BackupRestorePageState> staticGlobalKey =
      new GlobalKey<_BackupRestorePageState>();

  @override
  _BackupRestorePageState createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  Storage storage = new Storage();
  String backupPath = "";
  bool isUploading = false;
  final dbHelper = DatabaseHelper.instance;
  late SharedPreferences sharedPreferences;
  bool isLogged = false;

  getPref() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      if (isLogged = (sharedPreferences.getBool('is_logged') ?? false) &&
          (sharedPreferences.getBool('nextcloud_backup') ?? false))
        isUploading = true;
    });
    print(isLogged);
  }

  setPref() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {});
  }

  Future<void> _getBackupPath() async {
    final _path = await storage.localPath;
    setState(() {
      backupPath = _path;
    });
  }

  Future _makeBackup() async {
    var _notes = await dbHelper.getNotesAllForBackup();
    String out = "";
    _notes.forEach((element) {
      out += "{\"note_id\":\"${element.noteId}\", " +
          "\"note_date\": \"${element.noteDate}\", " +
          "\"note_title\": \"${element.noteTitle}\", " +
          "\"note_text\": \"${element.noteText.replaceAll('\n', '\\n')}\", " +
          "\"note_label\": \"${element.noteLabel}\", " +
          "\"note_archived\": ${element.noteArchived}, " +
          "\"note_color\": ${element.noteColor} },";
    });
    if (_notes.length > 0) {
      if (UniversalPlatform.isAndroid) {
        await storage
            .writeData("[" + out.substring(0, out.length - 1) + "]")
            .then((value) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Backup done'),
          ));
        });
      }
      if (UniversalPlatform.isIOS) {
        await storage
            .writeiOSData("[" + out.substring(0, out.length - 1) + "]")
            .then((value) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Backup done'),
          ));
        });
      }
      if (isUploading) {
        try {
          final client = NextCloudClient.withCredentials(
            Uri(host: sharedPreferences.getString('nc_host')),
            sharedPreferences.getString('nc_username') ?? '',
            sharedPreferences.getString('nc_password') ?? '',
          );

          await client.webDav.upload(
              File(backupPath + '/bnotes.backup').readAsBytesSync(),
              '/bnotes.backup');
        } on RequestException catch (e, stacktrace) {
          print(e.statusCode);
          print(e.body);
          print(stacktrace);
        }
      }
    }

    // Future listFiles(NextCloudClient client) async {
    //   final files = await client.webDav.ls('/');
    //   for (final file in files) {
    //     print(file.path);
    //   }
    // }

    // Future getdata() async {
    //   sharedPreferences = await SharedPreferences.getInstance();
    // }
  }

  Future _restore() async {
    if (isUploading) {
      try {
        final client = NextCloudClient.withCredentials(
          Uri(host: sharedPreferences.getString('nc_host')),
          sharedPreferences.getString('nc_username') ?? '',
          sharedPreferences.getString('nc_password') ?? '',
        );

        // final downloadedData =
        //     await client.webDav.downloadStream('/bnotes.backup').then((value) { print(value);});
        // ignore: unused_local_variable
        final downloadedBytes =
            client.webDav.download('/bnotes.backup').then((value) {
          print(value);
          String restoredString = new String.fromCharCodes(value);
          final parsed =
              json.decode(restoredString).cast<Map<String, dynamic>>();
          List<Notes> notesList = [];
          notesList =
              parsed.map<Notes>((json) => Notes.fromJson(json)).toList();
          dbHelper.deleteNotesAll();
          notesList.forEach((element) {
            // Test back resoration from old version backup to check if note_list field gives error
            dbHelper.insertNotes(new Notes(
                element.noteId,
                element.noteDate,
                element.noteTitle,
                element.noteText,
                element.noteLabel,
                element.noteArchived,
                element.noteColor,
                element.noteList));
          });
          Navigator.pop(context, 'yes');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Restored'),
          ));
        });
        // final file = File(backupPath + '/bnotes.backup');
        // if (file.existsSync()) {
        //   file.deleteSync();
        // }
        // final inputStream = file.openWrite();
        // await inputStream.addStream(downloadedData).then((value) {
        //   inputStream.close();
        // });
      } on RequestException catch (e, stacktrace) {
        print(e.statusCode);
        print(e.body);
        print(stacktrace);
      }
    } else {
      await storage.readData().then((value) {
        final parsed = json.decode(value).cast<Map<String, dynamic>>();
        List<Notes> notesList = [];
        notesList = parsed.map<Notes>((json) => Notes.fromJson(json)).toList();
        dbHelper.deleteNotesAll();
        notesList.forEach((element) {
          dbHelper.insertNotes(new Notes(
              element.noteId,
              element.noteDate,
              element.noteTitle,
              element.noteText,
              element.noteLabel,
              element.noteArchived,
              element.noteColor,
              element.noteList));
        });
        Navigator.pop(context, 'yes');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Restored'),
        ));
      });
    }
  }

  @override
  void initState() {
    getPref();
    _getBackupPath();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backup & Restore'),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: kGlobalOuterPadding,
                child: Text(
                  'Back up your notes onto your device/Nextcloud. You can restore the backup when you reinstall scrawl.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
              ),
              ListTile(
                title: Text('Back path'),
                subtitle: Text('~/0/Android/data/com.rsoft.bnotes/files'),
              ),
              Padding(
                padding: kGlobalOuterPadding,
                child: Container(
                  padding: EdgeInsets.all(2.0),
                  width: MediaQuery.of(context).size.width * .3,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: Colors.black26),
                ),
              ),
              ListTile(
                title: Text('Use Nextcloud'),
                trailing: UniversalPlatform.isIOS
                    ? CupertinoSwitch(
                        value: isUploading,
                        onChanged: (value) {
                          setState(() {
                            isUploading = value;
                            print(isUploading);
                          });
                        },
                      )
                    : Switch(
                        value: isUploading,
                        onChanged: (value) {
                          setState(() {
                            isUploading = value;
                            sharedPreferences.setBool(
                                'nextcloud_backup', isUploading);
                            print(isUploading);
                          });
                        },
                      ),
              ),
              // Switch(
              //   value: isUploading,
              //   onChanged: (value){
              //     setState(() {
              //       isUploading=value;
              //       print(isUploading);
              //     });
              //   },
              //   activeTrackColor: Colors.lightGreenAccent,
              //   activeColor: Colors.green,
              // ),
              // Container(
              //   padding: EdgeInsets.all(20.0),
              //   child: Text('Path: $backupPath'),
              // ),
              Row(
                children: [
                  // Container(
                  //   padding: EdgeInsets.all(20.0),
                  //   child: OutlinedButton.icon(
                  //     onPressed: () {
                  //       _makeBackup();
                  //       Navigator.pop(context);
                  //     },
                  //     icon: Icon(CupertinoIcons.cloud_upload),
                  //     label: Text('Backup'),
                  //   ),
                  // ),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: kSecondaryColor.withOpacity(0.2),
                        primary: kSecondaryColor,
                      ),
                      onPressed: () => _makeBackup(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_outlined),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Backup')
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: kPrimaryColor.withOpacity(0.2),
                        primary: kPrimaryColor,
                      ),
                      onPressed: () => _restore(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download_outlined),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Restore'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:bnotes/constants.dart';
import 'package:bnotes/pages/notes_page.dart';
import 'package:bnotes/widgets/textbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:bnotes/layout/adaptive.dart';

class HomePage extends StatelessWidget {
  const HomePage();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = isDisplayDesktop(context);
    final body = SafeArea(
      child: Padding(
        padding: isDesktop
            ? const EdgeInsets.symmetric(horizontal: 72, vertical: 48)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(),
      ),
    );

    if (isDesktop) {
      return Row(
        children: [
          ListDrawer(),
          Expanded(
            child: Scaffold(
              body: NotesPage(),
              // floatingActionButton: FloatingActionButton(
              //   onPressed: () {},
              //   child: Icon(Icons.add),
              //   tooltip: 'Add',
              // ),
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('BNote'),
        ),
        body: NotesPage(),
        drawer: ListDrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          tooltip: 'Add',
          child: Icon(
            Icons.add,
          ),
        ),
      );
    }
  }
}

class ListDrawer extends StatefulWidget {
  @override
  _ListDrawerState createState() => _ListDrawerState();
}

class _ListDrawerState extends State<ListDrawer> {
  static final numItems = 9;

  int selectedItem = 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Drawer(
      elevation: 1.0,
      child: SafeArea(
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  CircleAvatar(
                      backgroundColor: kAccentColor.withOpacity(0.9),
                      foregroundColor: Colors.white,
                      child: Icon(Icons.person)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Guest',
                      style: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.w100),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              selected: true,
              title: Text('Home'),
              leading: Icon(Icons.home_outlined),
              onTap: () {},
              // selectedTileColor: kAccentColor.withOpacity(0.5),
            ),
            ListTile(
              leading: Icon(Icons.search_outlined),
              title: Text('Search'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.archive_outlined),
              title: Text('Archive'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded),
              title: Text('Trash'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.backup_outlined),
              title: Text('Backup & Restore'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings_outlined),
              title: Text('Settings'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

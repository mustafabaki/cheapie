import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Database db;

void main() async {
  runApp(firstScreen());

  // Get a location using getDatabasesPath
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'demo.db');

  await deleteDatabase(path);

  db = await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
    // When creating the db, create the table

    await db.execute("""CREATE TABLE address_detail (
  postal_code INT NOT NULL,
  city VARCHAR(45) NOT NULL,
  PRIMARY KEY (postal_code))""");

    // add another table here......
    await db.execute(""" """);
  });

  var tableNames =
      (await db.query('sqlite_master', where: 'type = ?', whereArgs: ['table']))
          .map((row) => row['name'] as String)
          .toList(growable: false);
  print(tableNames);
}

class firstScreen extends StatefulWidget {
  @override
  _firstScreenState createState() => _firstScreenState();
}

class _firstScreenState extends State<firstScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Cheapie'),
        ),
        body: Column(
          children: [
            Center(
              child: Image(
                image: AssetImage('images/logo.png'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

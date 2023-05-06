import 'dart:ui';
import 'package:image/image.dart';

import 'package:flutter/foundation.dart';
import 'package:mein_digitaler_hausmeister/enums/ticket_status.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentsDirectory implements Exception {}

class DatabaseIsNotOpen implements Exception {}

class CouldNotDeleteUser implements Exception {}

class UserAlreadyExists implements Exception {}

class CouldNotFindUser implements Exception {}

class TicketService {
  Database? _db;

  Future<DatabaseUser> getUser({required String email}) async {
    final db = getDatabase();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser(
      {required String name, required String email}) async {
    final db = getDatabase();
    //check if user already exists
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable,
        {nameColumn: name.toLowerCase(), emailColumn: email.toLowerCase()});

    return DatabaseUser(id: userId, name: name, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    final db = getDatabase();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database getDatabase() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createTicketPhotoTable);
      await db.execute(createTicketTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String name;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.name,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        name = map[nameColumn] as String,
        email = map[emailColumn] as String;

  @override
  String toString() => 'User: Name = $name, ID = $id, E-Mail = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseTicketPhoto {
  final int id;
  final Image img;

  const DatabaseTicketPhoto({required this.id, required this.img});

  DatabaseTicketPhoto.fromRow(Map<String, int> map)
      : id = map[idColumn] as int,
        img = map[imgColumn] as Image;

  @override
  String toString() => 'Photo ID: $id';

  @override
  bool operator ==(covariant DatabaseTicketPhoto other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseTicket {
  final int id;
  final int userId;
  final int photoId;
  final String content;
  final TicketStatus status;

  const DatabaseTicket(
      {required this.id,
      required this.userId,
      required this.photoId,
      required this.content,
      required this.status});

  DatabaseTicket.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userColumn] as int,
        content = map[descriptionColumn] as String,
        photoId = map[imgColumn] as int,
        status = TicketStatus.values.byName(map[statusColumn] as String);

  @override
  String toString() =>
      'Ticket: ID = $id, ${userId.toString()}, content: $content, ${photoId.toString()}, status: ${status.toString()}';

  @override
  bool operator ==(covariant DatabaseTicket other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'ticket_db';
const idColumn = 'id';
const nameColumn = 'name';
const emailColumn = 'email';
const userColumn = 'user';
const descriptionColumn = 'description';
const imgColumn = 'image';
const statusColumn = 'status';
const userTable = "users";
const ticketPhotoTable = "ticket_photos";
const ticketTable = "tickets";
const createUserTable = '''CREATE TABLE IF NOT EXISTS "users" (
        "id" INTEGER NOT NULL,
        "name" TEXT NOT NULL;
        "email" TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
const createTicketPhotoTable = '''CREATE TABLE IF NOT EXISTS "ticket_photos" (
        "id" INTEGER NOT NULL,
        "image" TEXT NOT NULL;
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
const createTicketTable = '''CREATE TABLE IF NOT EXISTS "tickets" (
        "id" INTEGER NOT NULL,
        "ticketPhoto_id" INTEGER NOT NULL,
        "content" TEXT,
        "status" TEXT NOT NULL,
        "is_synced_with_cloud" INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY ("user_id") REFERENCES "users"("id"),
        FOREIGN KEY ("ticketPhoto_id") REFERENCES "ticket_photos"("id"),
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';

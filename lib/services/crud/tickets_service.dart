import 'dart:async';

import 'package:image/image.dart';

import 'package:flutter/foundation.dart';
import 'package:mein_digitaler_hausmeister/enums/ticket_status.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

import 'crud_exceptions.dart';

class TicketService {
  Database? _db;

  List<DatabaseTicket> _tickets = List.empty(growable: true);

  final _ticketsStreamController =
      StreamController<List<DatabaseTicket>>.broadcast();

  Future<void> _cacheNotes() async {
    final allTickets = await getAllTickets();
    _tickets = allTickets.toList();
    _ticketsStreamController.add(_tickets);
  }

  Future<DatabaseTicket> updateTicketDescription(
      {required DatabaseTicket ticket, required String description}) async {
    final db = _getDatabase();

    //make sure ticket exists
    await getTicket(userId: ticket.userId, ticketId: ticket.id);

    final updatesCount = await db.update(
      ticketTable,
      {descriptionColumn: description, isSyncedWithCloudColumn: 0},
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateTicket();
    } else {
      final updatedTicket =
          await getTicket(userId: ticket.userId, ticketId: ticket.id);
      _tickets.removeWhere((ticket) => ticket.id == updatedTicket.id);
      _tickets.add(updatedTicket);
      _ticketsStreamController.add(_tickets);
      return updatedTicket;
    }
  }

  Future<DatabaseUser> getOrCreateUser(
      {required String firstName,
      required String lastName,
      required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(
          firstName: firstName, lastName: lastName, email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<Iterable<DatabaseTicket>> getAllTickets() async {
    final db = _getDatabase();
    final tickets = await db.query(ticketTable);
    return tickets.map((ticketRow) => DatabaseTicket.fromRow(ticketRow));
  }

  Future<DatabaseTicket> getTicket(
      {required int userId, required int ticketId}) async {
    final db = _getDatabase();
    final tickets = await db.query(
      ticketTable,
      limit: 1,
      where: 'userId = ? AND ticketId = ?',
      whereArgs: [userId, ticketId],
    );
    if (tickets.isEmpty) {
      throw CouldNotFindTicket();
    } else {
      final ticket = DatabaseTicket.fromRow(tickets.first);
      _tickets.removeWhere((ticket) => ticket.id == ticketId);
      _tickets.add(ticket);
      _ticketsStreamController.add(_tickets);
      return ticket;
    }
  }

  Future<void> deleteTicket(
      {required int userId, required int ticketId}) async {
    final db = _getDatabase();
    final deletedCount = await db.delete(
      ticketTable,
      where: 'userId = ? AND ticketId = ?',
      whereArgs: [userId, ticketId],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteTicket();
    } else {
      _tickets.removeWhere((ticket) => ticket.id == ticketId);
      _ticketsStreamController.add(_tickets);
    }
  }

  Future<DatabaseTicket> createTicket({required DatabaseUser owner}) async {
    final db = _getDatabase();

    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    final ticketId = await db.insert(ticketTable, {
      userIdColumn: owner.id,
      imgIdColumn: Null,
      descriptionColumn: '',
      statusColumn: TicketStatus.open.toString(),
      isSyncedWithCloudColumn: 1
    });

    final ticket = DatabaseTicket(
        id: ticketId,
        userId: owner.id,
        imgId: null,
        description: '',
        status: TicketStatus.open,
        isSyncedWithCloud: true);

    _tickets.add(ticket);
    _ticketsStreamController.add(_tickets);

    return ticket;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabase();
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
      {required String firstName,
      required String lastName,
      required String email}) async {
    final db = _getDatabase();
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

    final userId = await db.insert(userTable, {
      firstNameColumn: firstName.toLowerCase(),
      lastNameColumn: lastName.toLowerCase(),
      emailColumn: email.toLowerCase()
    });

    return DatabaseUser(
        id: userId, firstName: firstName, lastName: lastName, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabase();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabase() {
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
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String firstName;
  final String lastName;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        firstName = map[firstNameColumn] as String,
        lastName = map[lastNameColumn] as String,
        email = map[emailColumn] as String;

  @override
  String toString() =>
      'User: First Name = $firstName, Last Name = $lastName, E-Mail = $email, ID = $id';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseTicketImage {
  final int id;
  final Image img;

  const DatabaseTicketImage({required this.id, required this.img});

  DatabaseTicketImage.fromRow(Map<String, int> map)
      : id = map[idColumn] as int,
        img = map[imgColumn] as Image;

  @override
  String toString() => 'Photo ID: $id';

  @override
  bool operator ==(covariant DatabaseTicketImage other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseTicket {
  final int id;
  final int userId;
  final int? imgId;
  final String description;
  final TicketStatus status;
  final bool isSyncedWithCloud;

  const DatabaseTicket(
      {required this.id,
      required this.userId,
      required this.imgId,
      required this.description,
      required this.status,
      required this.isSyncedWithCloud});

  DatabaseTicket.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        description = map[descriptionColumn] as String,
        imgId = map[imgIdColumn] as int?,
        status = TicketStatus.values.byName(map[statusColumn] as String),
        isSyncedWithCloud = map[isSyncedWithCloudColumn] as bool;

  @override
  String toString() =>
      'Ticket: ID = $id, ${userId.toString()}, description: $description, ${imgId.toString()}, status: ${status.toString()}, isSyncedWithCloud: ${isSyncedWithCloud.toString()}';

  @override
  bool operator ==(covariant DatabaseTicket other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'ticket_db';
const idColumn = 'id';
const userIdColumn = 'userId';
const firstNameColumn = 'firstName';
const lastNameColumn = 'lastName';
const emailColumn = 'email';
const imgColumn = 'image';
const userColumn = 'user';
const descriptionColumn = 'description';
const imgIdColumn = 'imageId';
const statusColumn = 'status';
const isSyncedWithCloudColumn = 'isSyncedWithCloud';
const userTable = "users";
const ticketPhotoTable = "ticket_photos";
const ticketTable = "tickets";
const createUserTable = '''CREATE TABLE IF NOT EXISTS "users" (
        "id" INTEGER NOT NULL,
        "firstName" TEXT NOT NULL,
        "lastName" TEXT NOT NULL,
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
        "userId" INTEGER NOT NULL,
        "imageId" INTEGER,
        "description" TEXT,
        "status" TEXT NOT NULL,
        "isSyncedWithCloud" INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY ("user_id") REFERENCES "users"("id"),
        FOREIGN KEY ("imageId") REFERENCES "ticket_photos"("id"),
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';

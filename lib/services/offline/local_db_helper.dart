import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DBHelper {
  // creating products table
  static const String myProductsTable = "CREATE TABLE IF NOT EXISTS products(" +
      "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL," +
      "name	TEXT NOT NULL," +
      "slug	TEXT NOT NULL," +
      "description	TEXT DEFAULT NULL," +
      "image TEXT DEFAULT NULL," +
      "price INTEGER NOT NULL," +
      "in_stock INTEGER NOT NULL DEFAULT 0," +
      "qty_per_order INTEGER NOT NULL DEFAULT 0," +
      "is_active INTEGER NOT NULL DEFAULT 1," +
      "created_at TEXT DEFAULT NULL," +
      "updated_at TEXT DEFAULT NULL" +
      ")";

  // creating sales table
  static const String mySalesTable = "CREATE TABLE IF NOT EXISTS sales(" +
      "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL," +
      "order_no	TEXT NOT NULL," +
      "ordered_at	TEXT NOT NULL," +
      "total REAL DEFAULT NULL," +
      "created_at TEXT DEFAULT NULL," +
      "updated_at TEXT DEFAULT NULL" +
      ")";

  // creating sale item table
  static const String mySalesItemTable =
      "CREATE TABLE IF NOT EXISTS sales_item(" +
          "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL," +
          "sale_id	INTEGER NOT NULL," +
          "product_id	INTEGER NOT NULL," +
          "unit_price	REAL NOT NULL," +
          "quantity INTEGER NOT NULL," +
          "price INTEGER NOT NULL," +
          "total REAL NOT NULL," +
          "created_at TEXT DEFAULT NULL," +
          "updated_at TEXT DEFAULT NULL" +
          ")";

  static Future<sql.Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return await sql.openDatabase(
      path.join(dbPath, "shopping.db"),
      onCreate: (db, version) {
        db.execute(myProductsTable);
        db.execute(mySalesTable);
        db.execute(mySalesItemTable);
      },
      version: 1,
    );
  }

  // insert value to a specific table
  static Future<int> insert(String table, Map<String, dynamic> data) async {
    int result = 0;
    final db = await DBHelper.database();
    result = await db.insert(table, data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return result;
  }

  // getAllClients() async {
  //   final db = await database;
  //   var res = await db.query("Client");
  //   List<Client> list =
  //   res.isNotEmpty ? res.map((c) => Client.fromMap(c)).toList() : [];
  //   return list;
  // }

  // to get all the record from the specific table

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    var res = await db.query(table);
    return res.isNotEmpty ? await db.query(table) : [];
  }

  // to update a field in a table
  static Future<void> updateById(
      String table, String column, String value, String id) async {
    final db = await DBHelper.database();
    await db.rawUpdate(
      "UPDATE  $table SET $column = '$value' WHERE id = '$id' ",
    );
  }

  static deleteItem(String id) async {
    final db = await DBHelper.database();
    return await db
        .rawDelete('DELETE FROM transaction_data WHERE id = ?', [id]);
  }

  // truncate table
  static Future<void> truncateTable(String tableName) async {
    final db = await DBHelper.database();
    await db.rawDelete('DELETE FROM $tableName ');
  }

  static close() async {
    final db = await DBHelper.database();
    db.close();
  }
}

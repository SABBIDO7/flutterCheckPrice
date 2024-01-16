// ignore_for_file: avoid_print, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class YourDatabaseHelper {
  static final YourDatabaseHelper _instance = YourDatabaseHelper._internal();

  factory YourDatabaseHelper() => _instance;

  YourDatabaseHelper._internal();

  late Database _database;

  Future<Database> get database async {
    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dbName = prefs.getString('dbName');
    final path = join(databasesPath, '$dbName.db');
    // final pathtest = join(databasesPath, 'l.db');
    // if (pathtest.isNotEmpty) {
    //   print("mawjoud ");
    // } else {
    //   print("msh maejoud");
    // }

    WidgetsFlutterBinding.ensureInitialized();
    print(path);
    print("trying...");

    return await openDatabase(
      path,
      onConfigure: (db) async {
        // Create tables here
        print("createdddddd tableeee");
        await db.execute('''
         CREATE TABLE IF NOT EXISTS dc_items (
  `itemNumber` VARCHAR(20) NULL DEFAULT NULL COLLATE NOCASE,
  `GOID` VARCHAR(20) NULL DEFAULT NULL COLLATE NOCASE,
  `itemName` VARCHAR(120) NULL DEFAULT NULL COLLATE NOCASE,
  `Branch` VARCHAR(10) NULL DEFAULT NULL COLLATE NOCASE,
  `quantity` DOUBLE NULL DEFAULT NULL,
  `S1` DOUBLE NULL DEFAULT NULL,
  `S2` DOUBLE NULL DEFAULT NULL,
  `S3` DOUBLE NULL DEFAULT NULL,
  `handQuantity` DOUBLE NULL DEFAULT NULL,
  `vat` DOUBLE NULL DEFAULT NULL,
  `sp` VARCHAR(5) NULL DEFAULT NULL COLLATE NOCASE,
  `costPrice` DOUBLE NULL DEFAULT NULL,
  `image` VARCHAR(150) NULL DEFAULT NULL COLLATE NOCASE,
  `Disc1` DOUBLE NULL DEFAULT NULL,
  `Disc2` DOUBLE NULL DEFAULT NULL,
  `Disc3` DOUBLE NULL DEFAULT NULL,
  `Qunit` DOUBLE NULL DEFAULT NULL
);''');
      },
    );
  }

  Future<void> insertData(List<YourDataModel> data) async {
    await delete_dc_items();
    print("lek");
    List<String> databaseList = [];

    try {
      final databasesPath = await getDatabasesPath();
      final dbDirectory = Directory(databasesPath);
      final dbFiles = dbDirectory.list();

      await for (var file in dbFiles) {
        if (file is File && file.path.endsWith('.db')) {
          // It's a SQLite database file
          print("ana bl looop");
          print(file.path);
          databaseList.add(file.path);
        }
      }
      print("lllll::: $databaseList");
    } catch (e) {
      print('Error listing databases: $e');
    }
    final Database db = await database;

    for (YourDataModel item in data) {
      await db.insert('dc_items', item.toMap());
      print("data inserted");
    }
  }

  Future<void> deleteData() async {
    final Database db = await database;

    await db.delete('dc_items');
    print("data deleted");
  }

  // Future<void> deleteDatabaseFile() async {
  //   // Ensure the file exists before attempting to delete
  //   final databasesPath = await getDatabasesPath();
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? dbName = prefs.getString('dbName');
  //   final path = join(databasesPath, '$dbName.db');
  //   //bool fileExists = await databaseExists(path);
  //   if (await databaseExists(path)) {
  //     print("lek waynooo");
  //     await deleteDatabase(path);
  //     print('Database file deleted');
  //   } else {
  //     print('Database file not found');
  //   }
  // }

  Future<void> delete_dc_items() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dbName = prefs.getString('dbName');

    String path = join(await getDatabasesPath(), '$dbName.db');
    if (await databaseExists(path)) {
      Database database = await openDatabase(path);

      await database.execute('DROP TABLE IF EXISTS dc_items');

      await database.close();
    }
  }

  Future<List<dynamic>> getBranches() async {
    final Database db = await database;

    try {
      final List<Map<String, dynamic>> distinctBranches = await db.rawQuery(
        'SELECT DISTINCT branch FROM dc_items',
      );

      final List<String> branches =
          distinctBranches.map((row) => row['Branch'].toString()).toList();

      return branches;
    } catch (e) {
      print('Error fetching branches: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getItem(String itemNumber) async {
    final Database db = await database;

    try {
      final List<Map<String, dynamic>> itemsResult = await db.query(
        'dc_items',
        where: 'itemNumber = ?',
        whereArgs: [itemNumber.toUpperCase()],
        limit: 1,
      );
      print('Items Result: $itemsResult');

      if (itemsResult.isNotEmpty) {
        final Map<String, dynamic> item = itemsResult.first;

        final List<Map<String, dynamic>> branchQuantities = await db.rawQuery(
          'SELECT branch, SUM(quantity) as totalQuantity '
          'FROM dc_items '
          'WHERE itemNumber = ? GROUP BY branch',
          [itemNumber.toUpperCase()],
        );
        List<Map<String, dynamic>> itemQuantities = branchQuantities
            .map((branch) => {
                  'branch': branch['Branch'],
                  'quantity': branch['totalQuantity'],
                })
            .toList();
        print('Branch Quantities: $itemQuantities');

        final List<Map<String, dynamic>> totalQuantityResult =
            await db.rawQuery(
          'SELECT SUM(quantity) as totalQuantity '
          'FROM dc_items '
          'WHERE itemNumber = ?',
          [itemNumber.toUpperCase()],
        );
        print('Total Quantity Result: $totalQuantityResult');

        final List<Map<String, dynamic>> branchesNumberResult =
            await db.rawQuery(
          'SELECT DISTINCT branch FROM dc_items WHERE itemNumber = ?',
          [itemNumber.toUpperCase()],
        );

        int branchesNumber = branchesNumberResult.length;
        print('Branches Number: $branchesNumber');

        return {
          "item": item,
          "itemQB": itemQuantities,
          "totalQuantity": totalQuantityResult[0]['totalQuantity'] ?? 0,
          "branches_number": branchesNumber,
        };
      } else {
        return {"item": "empty"};
      }
    } catch (e) {
      print('Error fetching item: $e');
      return {"error": "An error occurred while fetching the item"};
    }
  }

  Future<List<Map<String, dynamic>>> getInventories(String? username) async {
    final Database db = await database;
    List<Map<String, dynamic>> tableInfos = [];

    try {
      // Replace 'username' with the actual value you want to query
      String query =
          "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'DC_${username}_%'";
      final List<Map<String, dynamic>> result = await db.rawQuery(query);
      print("----------------------------------$result");

      if (result.isNotEmpty) {
        List<String> tableNames =
            result.map((row) => row['name'].toString()).toList();
        print(tableNames);

        await Future.wait(tableNames.map((tableName) async {
          String rowCountQuery = "SELECT COUNT(*) FROM $tableName";
          print(rowCountQuery);
          int? rowCount =
              Sqflite.firstIntValue(await db.rawQuery(rowCountQuery));
          print(rowCount);
          tableInfos.add({
            "table_name": tableName,
            "row_count": rowCount,
            "update_time": '',
          });
        }));
        print("from invvvvvv----------------");
        print(tableInfos);
        return tableInfos;
      } else {
        return [];
      }
    } catch (e) {
      print('Error checking tables: $e');
      return [];
    }
  }

  Future<String> createInventoryTable(
      String username, String dbName, String inventory) async {
    final Database db = await database;
    final currentDateTime = DateTime.now();
    String abbreviatedDay =
        DateFormat.E().format(currentDateTime).substring(0, 2).toLowerCase();
    // String currentDayName = DateTime.now().toLocal().toString().split(' ')[0];

    String formattedDatetime =
        DateFormat("yyyyMMdd_HHmmss").format(currentDateTime);

    formattedDatetime = "$abbreviatedDay$formattedDatetime";
    print("foramted date only :$formattedDatetime");
    try {
      // Check if the table already exists
      String checkQuery =
          "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'DC_${username}_$inventory%'";

      final List<Map<String, dynamic>> result = await db.rawQuery(checkQuery);

      if (result.isNotEmpty) {
        print(result[0]);
        print("already exsists");
        return "False";
      }
      username = username.toLowerCase();
      inventory = inventory.toLowerCase();
      // Create the table
      String createQuery =
          "CREATE TABLE dc_${username}_${inventory}_${formattedDatetime}_off ("
          "itemNumber VARCHAR(20) NULL DEFAULT NULL,"
          "GOID VARCHAR(20) NULL DEFAULT NULL,"
          "itemName VARCHAR(120) NULL DEFAULT NULL,"
          "Branch VARCHAR(10) NULL DEFAULT NULL,"
          "quantity DOUBLE NULL DEFAULT NULL,"
          "S1 DOUBLE NULL DEFAULT NULL,"
          "S2 DOUBLE NULL DEFAULT NULL,"
          "S3 DOUBLE NULL DEFAULT NULL,"
          "handQuantity DOUBLE NULL DEFAULT NULL,"
          "vat DOUBLE NULL DEFAULT NULL,"
          "sp VARCHAR(5) NULL DEFAULT NULL,"
          "costPrice DOUBLE NULL DEFAULT NULL,"
          "image VARCHAR(150) NULL DEFAULT NULL,"
          "Disc1 DOUBLE NULL DEFAULT NULL,"
          "Disc2 DOUBLE NULL DEFAULT NULL,"
          "Disc3 DOUBLE NULL DEFAULT NULL,"
          "Qunit DOUBLE NULL DEFAULT NULL"
          ")";

      await db.execute(createQuery);

      // Check if the table was successfully created
      String checkAfterQuery =
          "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'DC_${username}_$inventory%'";

      final List<Map<String, dynamic>> checkResult =
          await db.rawQuery(checkAfterQuery);

      if (checkResult.isNotEmpty) {
        print("akal nkhal2et");
        return checkResult[0]['name'];
      } else {
        print("error in creation");
        return "False";
      }
    } catch (e) {
      print("catchhhhhh");
      return "False";
    }
  }

  Future<Map<String, dynamic>> getInventoryItem(
      String itemNumber, String branch, String inventory) async {
    final Database db = await database;

    try {
      List<Map<String, dynamic>> rows = await db.rawQuery(
          'SELECT * FROM $inventory WHERE itemNumber=? AND Branch=? LIMIT 1',
          [itemNumber.toUpperCase(), branch.toUpperCase()]);

      if (rows.isNotEmpty) {
        Map<String, dynamic> row = rows.first;
        print("sari3a");
        // Your image processing logic here

        return {
          "status": true,
          "message": "The item is fetched from the inventory table",
          "item": row,
        };
      } else {
        print("fet bel elseeee");
        List<Map<String, dynamic>> dcItemRow = await db.query(
          'dc_items',
          where: 'itemNumber=? AND Branch=?',
          whereArgs: [itemNumber.toUpperCase(), branch.toUpperCase()],
          limit: 1,
        );
        if (dcItemRow.isEmpty) {
          print("male2e maa branchhh");
          dcItemRow = await db.query(
            'dc_items',
            where: 'itemNumber=?',
            whereArgs: [itemNumber.toUpperCase()],
            limit: 1,
          );
        }
        if (dcItemRow.isNotEmpty) {
          print("selke");
          for (Map<String, Object?> item in dcItemRow) {
            print("abel ma taazim");
            print(item);
            YourDataModel decerialized = YourDataModel.fromJson(item);

            decerialized.Branch = branch;
            print(decerialized);
            Map<String, Object?> finalItem = decerialized.toMap();
            print("azamit");
            await db.insert(inventory, finalItem);
            print("inserted");
          }
          List dcInventoryItem = await db.rawQuery(
              'SELECT * FROM $inventory WHERE itemNumber=? AND Branch=? LIMIT 1',
              [itemNumber.toUpperCase(), branch.toUpperCase()]);
          if (dcInventoryItem.isNotEmpty) {
            for (var item in dcInventoryItem) {
              print("from the inventory table:");
              return {"status": true, "message": "Item inserted", "item": item};
            }
          } else {
            return {
              "status": false,
              "message": "Item not found why1",
              "item": "{}"
            };
          }
        }
        return {
          "status": false,
          "message": "Item not found why2",
          "item": "{}"
        };

        // Handle case where item is not found in the specified inventory
      }
    } catch (e) {
      // Handle errors
      print('Error: $e');
      return {"status": false, "message": "Error retrieving item", "item": {}};
    }
  }

  Future<Map<String, dynamic>> updateHandQuantity(
      String itemNumber,
      double handQuantity,
      String branch,
      String inventory,
      double oldHandQuantity) async {
    final Database db = await database;

    try {
      // Calculate the new totalHandQuantity
      double totalHandQuantity = handQuantity + oldHandQuantity;

      // Update the handQuantity in the database
      await db.rawUpdate('''
      UPDATE $inventory 
      SET handQuantity = ? 
      WHERE itemNumber = UPPER(?)
    ''', [totalHandQuantity, itemNumber.toUpperCase()]);

      return {"status": true, "message": "Hand Quantity updated successfully"};
    } catch (e) {
      // Handle errors
      throw Exception("Internal Server Error: $e");
    }
  }

  Future<Map<String, dynamic>> createItem(String itemNumber, String itemName,
      String inventory, String branch, double handQuantity) async {
    final Database db = await database;

    try {
      YourDataModel item = YourDataModel(
          itemName: itemName.toUpperCase(),
          itemNumber: itemNumber.toUpperCase(),
          GOID: itemNumber.toUpperCase(),
          Branch: branch.toUpperCase(),
          quantity: 0.0,
          S1: 0.0,
          S2: 0.0,
          S3: 0.0,
          handQuantity: handQuantity,
          vat: 0.0,
          sp: "",
          costPrice: 0.0,
          image: "",
          Disc1: 0.0,
          Disc2: 0.0,
          Disc3: 0.0,
          Qunit: 1);
      await db.insert(inventory, item.toMap());
      return {"status": true, "message": "Item inserted successfully"};
    } catch (e) {
      return {
        "status": false,
        "message": "Error checking tables: $e",
        "item": "empty"
      };
    }
  }

  // Future<void> deleteTablesStartingWith(String dbName, String prefix) async {
  //   String path = join(await getDatabasesPath(), '$dbName.db');
  //   Database database = await openDatabase(path);

  //   // Get all table names starting with the specified prefix
  //   List<String> tableNames = await database
  //       .rawQuery(
  //         "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE '$prefix%'",
  //       )
  //       .then((value) => value
  //           .map((Map<String, dynamic> map) => map['name'].toString())
  //           .toList());

  //   // Delete each table
  //   for (String tableName in tableNames) {
  //     await database.execute('DROP TABLE IF EXISTS $tableName');
  //     print("drop");
  //   }

  //   await database.close();
  // }
  Future<void> deleteTable(String dbName, String inventory) async {
    String path = join(await getDatabasesPath(), '$dbName.db');
    Database database = await openDatabase(path);

    // Get all table names starting with the specified prefix
    List<String> tableNames = await database
        .rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name = '$inventory'",
        )
        .then((value) => value
            .map((Map<String, dynamic> map) => map['name'].toString())
            .toList());

    // Delete each table
    for (String tableName in tableNames) {
      await database.execute('DROP TABLE IF EXISTS $tableName');
      print("drop");
    }

    await database.close();
  }

  Future<List<YourDataModel>> getAllItems() async {
    final Database db = await database;

    // Query all rows from the 'dc_item' table
    final List<Map<String, dynamic>> result = await db.query('dc_items');

    // Convert the List<Map> to a List<YourDataModel>
    final List<YourDataModel> items = result.map((map) {
      return YourDataModel(
        itemName: map['itemName'],
        itemNumber: map['itemNumber'],
        GOID: map['GOID'],
        Branch: map['Branch'],
        quantity: map['quantity'],
        S1: map['S1'],
        S2: map['S2'],
        S3: map['S3'],
        handQuantity: map['handQuantity'],
        vat: map['vat'],
        sp: map['sp'],
        costPrice: map['costPrice'],
        image: map['image'],
        Disc1: map['Disc1'],
        Disc2: map['Disc2'],
        Disc3: map['Disc3'],
        Qunit: map['Qunit'],
      );
    }).toList();

    return items;
  }
}

class YourApiService {
  Future<List<YourDataModel>> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString('ip');
    String? dbName = prefs.getString('dbName');
    final url = Uri.parse(
        'http://$ip/getAllItems/?dbName=$dbName'); // Replace with your API endpoint

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = await json
            .decode(utf8.decode(response.bodyBytes, allowMalformed: true));
        print(jsonList);
        List<YourDataModel> wholeData =
            jsonList.map((json) => YourDataModel.fromJson(json)).toList();

        return wholeData;
      } else {
        return [];
        //throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e);
      return [];
    }
  }
}

class YourDataModel {
  // Define your data model properties and methods here

  final String itemName;
  final String itemNumber;
  final String GOID;
  String Branch;
  final double quantity;
  final double S1;
  final double S2;
  final double S3;
  final double handQuantity;
  final double vat;
  final String sp;
  final double costPrice;
  final String image;
  final double Disc1;
  final double Disc2;
  final double Disc3;
  final double Qunit;

  YourDataModel({
    required this.itemName,
    required this.itemNumber,
    required this.GOID,
    required this.Branch,
    required this.quantity,
    required this.S1,
    required this.S2,
    required this.S3,
    required this.handQuantity,
    required this.vat,
    required this.sp,
    required this.costPrice,
    required this.image,
    required this.Disc1,
    required this.Disc2,
    required this.Disc3,
    required this.Qunit,
  });

  factory YourDataModel.fromJson(Map<String, dynamic> json) {
    // Implement conversion from JSON to YourDataModel
    return YourDataModel(
      itemName: json['itemName'] ?? '',
      itemNumber: json['itemNumber'] ?? '',
      GOID: json['GOID'] ?? '',
      Branch: json['Branch'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      S1: (json['S1'] ?? 0).toDouble(),
      S2: (json['S2'] ?? 0).toDouble(),
      S3: (json['S3'] ?? 0).toDouble(),
      handQuantity: (json['handQuantity'] ?? 0).toDouble(),
      vat: (json['vat'] ?? 0).toDouble(),
      sp: json['sp'] ?? '',
      costPrice: (json['costPrice'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      Disc1: (json['Disc1'] ?? 0).toDouble(),
      Disc2: (json['Disc2'] ?? 0).toDouble(),
      Disc3: (json['Disc3'] ?? 0).toDouble(),
      Qunit: (json['Qunit'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'itemNumber': itemNumber,
      'GOID': GOID,
      'Branch': Branch,
      'quantity': quantity,
      'S1': S1,
      'S2': S2,
      'S3': S3,
      'handQuantity': handQuantity,
      'vat': vat,
      'sp': sp,
      'costPrice': costPrice,
      'image': image,
      'Disc1': Disc1,
      'Disc2': Disc2,
      'Disc3': Disc3,
      'Qunit': Qunit,
    };
  }
}

class YourDataSync {
  final YourApiService apiService = YourApiService();
  final YourDatabaseHelper databaseHelper = YourDatabaseHelper();

  Future<bool> syncData() async {
    if (await isConnected()) {
      try {
        print("masa l kher");
        final List<YourDataModel> data = await apiService.fetchData();
        print("dataaaaaa:  $data");
        await databaseHelper.insertData(data);
        List<YourDataModel> items = await databaseHelper.getAllItems();

        for (YourDataModel item in items) {
          print('Item Name: ${item.itemName}');
          print('Item Number: ${item.itemNumber}');
          print('GOID: ${item.GOID}');

          // ... and so on, access other properties in a similar manner
        }
        return true;
      } catch (e) {
        print('Error syncing data: $e');
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> uploadData(String username, String inventory) async {
    final Database db = await YourDatabaseHelper().database;

    if (await isConnected()) {
      try {
        List<Map<String, List<Map<String, dynamic>>>> result = [];
        List tables = [];
        List rowst = [];

        // Get all table names starting with "dc_user_"
        List<String> tableNames = await db
            .rawQuery(
              "SELECT name FROM sqlite_master WHERE type='table' AND name = '$inventory'",
            )
            .then((value) => value
                .map((Map<String, dynamic> map) => map['name'].toString())
                .toList());

        // Fetch data for each table

        for (String tableName in tableNames) {
          // Get all rows from the current table
          List<Map<String, dynamic>> rows = await db.query(tableName);
          tables.add(tableName);
          rowst.add(rows);
          // Store rows in the result map
          // Create an entry for the current table in the result list
          Map<String, List<Map<String, dynamic>>> tableEntry = {
            tableName: rows,
          };
          print(tableEntry);
          print("---------------");
          // Store the entry in the result list
          result.add(tableEntry);
        }

        print("------------resss");
        print(result);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? ip = prefs.getString('ip');
        String? dbName = prefs.getString('dbName');
        // Replace with your FastAPI login endpoint

        try {
          //List<Map<String,Object>> rowstJson = jsonEncode(rowst);
          //String tablesJson = jsonEncode(tables);

          final url = Uri.parse('http://$ip/uploadData/?dbName=$dbName');
// Replace with your FastAPI endpoint

// Include 'rowstJson' and 'tablesJson' in the request body
          final response = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'result': rowst,
              'result2': tables,
            }),
          );
          //print(response);

          if (response.statusCode == 200) {
            // Handle success
            final data = jsonDecode(
                utf8.decode(response.bodyBytes, allowMalformed: true));
            if (data["status"] == true) {
              return true;
            } else {
              return false;
            }
          } else {
            // Handle failure
            print("Failure");
            return false;
          }
        } catch (e) {
          print('Error syncing data: $e');
          return false;
        }
      } catch (e) {
        print('Error syncing data: $e');
        return false;
      }
    } else {
      // Handle no internet connection
      print('No internet connection');
      return false;
    }
  }

  Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;
  }
}

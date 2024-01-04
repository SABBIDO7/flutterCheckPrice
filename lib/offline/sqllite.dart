import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final path = join(databasesPath, 'your_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create tables here
        await db.execute('''
         CREATE TABLE IF NOT EXISTS dc_item (
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
    final Database db = await database;
    for (YourDataModel item in data) {
      await db.insert('dc_item', item.toMap());
    }
  }
}

class YourApiService {
  Future<List<YourDataModel>> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString('ip');
    String? dbName = prefs.getString('dbName');
    print("fet aal service");
    final url = Uri.parse(
        'http://$ip/getAllItems/?dbName=$dbName'); // Replace with your API endpoint

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => YourDataModel.fromJson(json)).toList();
      } else {
        return [];
        //throw Exception('Failed to load data');
      }
    } catch (e) {
      return [];
    }
  }
}

class YourDataModel {
  // Define your data model properties and methods here

  final String itemName;
  final String itemNumber;
  final String GOID;
  final String Branch;
  final double quantity;
  final double S1;
  final double S2;
  final double S3;
  final double handQuantity;
  final double vat;
  final double sp;
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
      sp: (json['sp'] ?? 0).toDouble(),
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

  Future<void> syncData() async {
    if (await _isConnected()) {
      try {
        print("masa l kher");
        final List<YourDataModel> data = await apiService.fetchData();
        print(data);
        await databaseHelper.insertData(data);
      } catch (e) {
        print('Error syncing data: $e');
      }
    } else {
      print('No internet connection');
    }
  }

  Future<bool> _isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;
  }
}

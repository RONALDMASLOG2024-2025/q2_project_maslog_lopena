import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/recycling_resource.dart';

abstract class RecyclingRepository {
  Future<RecyclingDirectory> loadDirectory();
}

class LocalRecyclingRepository implements RecyclingRepository {
  final String assetPath;
  const LocalRecyclingRepository({this.assetPath = 'assets/data/recycling_resources.json'});

  @override
  Future<RecyclingDirectory> loadDirectory() async {
    final raw = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> jsonMap = json.decode(raw) as Map<String, dynamic>;
    return RecyclingDirectory.fromJson(jsonMap);
  }
}

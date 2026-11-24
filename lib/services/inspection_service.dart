import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/inspection_record.dart';

class InspectionService {
  Future<File> _getRecordsFile() async {
    final directory = await getApplicationDocumentsDirectory();

    return File('${directory.path}/inspections.json');
  }

  Future<List<InspectionRecord>> getInspections() async {
    final file = await _getRecordsFile();

    if (!await file.exists()) {
      return [];
    }

    final content = await file.readAsString();

    if (content.isEmpty) {
      return [];
    }

    final List<dynamic> jsonList = jsonDecode(content);

    return jsonList
        .map((json) => InspectionRecord.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveInspection(InspectionRecord record) async {
    final file = await _getRecordsFile();

    final inspections = await getInspections();

    inspections.insert(0, record);

    final jsonList = inspections
        .map((inspection) => inspection.toJson())
        .toList();

    await file.writeAsString(jsonEncode(jsonList));
  }

  Future<void> deleteInspection(String id) async {
    final file = await _getRecordsFile();

    final inspections = await getInspections();

    final recordToDelete = inspections.where((item) => item.id == id);

    if (recordToDelete.isEmpty) {
      return;
    }

    final record = recordToDelete.first;
    final imageFile = File(record.imagePath);

    if (await imageFile.exists()) {
      await imageFile.delete();
    }

    inspections.removeWhere((item) => item.id == id);

    final jsonList = inspections
        .map((inspection) => inspection.toJson())
        .toList();

    await file.writeAsString(jsonEncode(jsonList));
  }
}

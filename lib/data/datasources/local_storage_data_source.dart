import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constant/app_constants.dart';

import '../../data/model/scan_result_model.dart';

/// Data source for local storage operations
/// Handles persistence using SharedPreferences
abstract class LocalStorageDataSource {
  Future<bool> saveScan(ScanResultModel scanResult);
  Future<List<ScanResultModel>> getAllScans();
  Future<bool> deleteScan(String id);
  Future<bool> clearAll();
  Future<bool> updateScan(ScanResultModel scanResult);
}

class LocalStorageDataSourceImpl implements LocalStorageDataSource {
  final SharedPreferences sharedPreferences;

  LocalStorageDataSourceImpl(this.sharedPreferences);

  /// Get all scans from storage
  Future<List<ScanResultModel>> _getScans() async {
    try {
      final String? scansJson = sharedPreferences.getString(
        AppConstants.scanHistoryKey,
      );
      if (scansJson == null || scansJson.isEmpty) {
        return [];
      }

      final List<dynamic> scansList = json.decode(scansJson);
      return scansList
          .map((item) => ScanResultModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting scans: $e');
      return [];
    }
  }

  /// Save scans list to storage
  Future<bool> _saveScans(List<ScanResultModel> scans) async {
    try {
      final List<Map<String, dynamic>> scansJson = scans
          .map((scan) => scan.toJson())
          .toList();
      final String jsonString = json.encode(scansJson);
      return await sharedPreferences.setString(
        AppConstants.scanHistoryKey,
        jsonString,
      );
    } catch (e) {
      print('Error saving scans: $e');
      return false;
    }
  }

  @override
  Future<bool> saveScan(ScanResultModel scanResult) async {
    try {
      final scans = await _getScans();

      // Add new scan at the beginning (most recent first)
      scans.insert(0, scanResult);

      // Limit history size
      if (scans.length > AppConstants.maxHistoryItems) {
        scans.removeRange(AppConstants.maxHistoryItems, scans.length);
      }

      return await _saveScans(scans);
    } catch (e) {
      print('Error saving scan: $e');
      return false;
    }
  }

  @override
  Future<List<ScanResultModel>> getAllScans() async {
    return await _getScans();
  }

  @override
  Future<bool> deleteScan(String id) async {
    try {
      final scans = await _getScans();
      scans.removeWhere((scan) => scan.id == id);
      return await _saveScans(scans);
    } catch (e) {
      print('Error deleting scan: $e');
      return false;
    }
  }

  @override
  Future<bool> clearAll() async {
    try {
      return await sharedPreferences.remove(AppConstants.scanHistoryKey);
    } catch (e) {
      print('Error clearing scans: $e');
      return false;
    }
  }

  @override
  Future<bool> updateScan(ScanResultModel scanResult) async {
    try {
      final scans = await _getScans();
      final index = scans.indexWhere((scan) => scan.id == scanResult.id);

      if (index != -1) {
        scans[index] = scanResult;
        return await _saveScans(scans);
      }

      return false;
    } catch (e) {
      print('Error updating scan: $e');
      return false;
    }
  }
}

import '../entities/scan_result.dart';

/// Abstract repository interface defining contracts for scan operations
/// Implementation will be in the data layer
abstract class ScanRepository {
  /// Scan QR code or barcode using device camera
  /// Returns the scanned code value or null if failed/cancelled
  Future<String?> scanCode();

  /// Save a scan result to local storage
  /// Returns true if saved successfully
  Future<bool> saveScan(ScanResult scanResult);

  /// Get all scan history from local storage
  /// Returns list of scan results sorted by date (newest first)
  Future<List<ScanResult>> getScanHistory();

  /// Delete a specific scan from history
  /// Returns true if deleted successfully
  Future<bool> deleteScan(String id);

  /// Delete all scan history
  /// Returns true if cleared successfully
  Future<bool> clearHistory();

  /// Toggle favorite status of a scan
  /// Returns updated ScanResult
  Future<ScanResult> toggleFavorite(String id);

  /// Get only favorite scans
  Future<List<ScanResult>> getFavoriteScans();

  /// Search scans by value
  Future<List<ScanResult>> searchScans(String query);
}

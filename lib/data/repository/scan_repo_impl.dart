import '../../domain/entities/scan_result.dart';
import '../../domain/repository/scan_repository.dart';
import '../datasources/local_storage_data_source.dart';
import '../../data/datasources/scan_datasouce.dart';
import '../../data/model/scan_result_model.dart';

/// Implementation of ScanRepository
/// Coordinates between data sources and domain layer
class ScanRepositoryImpl implements ScanRepository {
  final ScanDataSource scanDataSource;
  final LocalStorageDataSource localStorageDataSource;

  ScanRepositoryImpl({
    required this.scanDataSource,
    required this.localStorageDataSource,
  });

  @override
  Future<String?> scanCode() async {
    return await scanDataSource.scanCode();
  }

  @override
  Future<bool> saveScan(ScanResult scanResult) async {
    final model = ScanResultModel.fromEntity(scanResult);
    return await localStorageDataSource.saveScan(model);
  }

  @override
  Future<List<ScanResult>> getScanHistory() async {
    final models = await localStorageDataSource.getAllScans();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<bool> deleteScan(String id) async {
    return await localStorageDataSource.deleteScan(id);
  }

  @override
  Future<bool> clearHistory() async {
    return await localStorageDataSource.clearAll();
  }

  @override
  Future<ScanResult> toggleFavorite(String id) async {
    final scans = await localStorageDataSource.getAllScans();
    final scanIndex = scans.indexWhere((scan) => scan.id == id);

    if (scanIndex != -1) {
      final updatedScan = scans[scanIndex].copyWith(
        isFavorite: !scans[scanIndex].isFavorite,
      );
      await localStorageDataSource.updateScan(updatedScan);
      return updatedScan.toEntity();
    }

    throw Exception('Scan not found');
  }

  @override
  Future<List<ScanResult>> getFavoriteScans() async {
    final scans = await getScanHistory();
    return scans.where((scan) => scan.isFavorite).toList();
  }

  @override
  Future<List<ScanResult>> searchScans(String query) async {
    final scans = await getScanHistory();
    final lowercaseQuery = query.toLowerCase();

    return scans.where((scan) {
      return scan.value.toLowerCase().contains(lowercaseQuery) ||
          scan.type.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}

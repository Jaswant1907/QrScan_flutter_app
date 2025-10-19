import '../../domain/repository/scan_repository.dart';

/// Use case for deleting a scan from history
class DeleteScanUseCase {
  final ScanRepository repository;

  DeleteScanUseCase(this.repository);

  /// Execute delete operation
  /// Returns true if deleted successfully
  Future<bool> execute(String id) async {
    try {
      return await repository.deleteScan(id);
    } catch (e) {
      print('DeleteScanUseCase Error: $e');
      return false;
    }
  }
}

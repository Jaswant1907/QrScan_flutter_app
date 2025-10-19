import '../entities/scan_result.dart';
import '../../domain/repository/scan_repository.dart';

/// Use case for retrieving scan history
class GetHistoryUseCase {
  final ScanRepository repository;

  GetHistoryUseCase(this.repository);

  /// Execute get history operation
  /// Returns list of all scan results
  Future<List<ScanResult>> execute() async {
    try {
      return await repository.getScanHistory();
    } catch (e) {
      print('GetHistoryUseCase Error: $e');
      return [];
    }
  }
}

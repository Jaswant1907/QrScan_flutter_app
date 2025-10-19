import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/usecases/scan_code_usecases.dart';
import '../../domain/usecases/save_scan_usecases.dart';
import '../../domain/usecases/get_history_usecases.dart';
import '../../domain/usecases/delet_scan_usecases.dart';
// import '../../domain/usecases/delete_scan_usecase.dart';
// import '../../domain/usecases/delete_scan_usecase.dart';

class ScanProvider extends ChangeNotifier {
  final ScanCodeUseCase scanCodeUseCase;
  final SaveScanUseCase saveScanUseCase;
  final GetHistoryUseCase getHistoryUseCase;
  final DeleteScanUseCase deleteScanUseCase;

  ScanProvider({
    required this.scanCodeUseCase,
    required this.saveScanUseCase,
    required this.getHistoryUseCase,
    required this.deleteScanUseCase,
  });

  String? scannedValue;
  List<ScanResult> history = [];
  bool isLoading = false;

  Future<void> scanCode() async {
    isLoading = true;
    notifyListeners();

    final result = await scanCodeUseCase.execute();
    scannedValue = result;
    if (result != null) {
      final scan = ScanResult(
        id: Uuid().v4(),
        value: result,
        type: result.startsWith('http') ? 'QR Code' : 'Barcode',
        scannedAt: DateTime.now(),
      );
      await saveScanUseCase.execute(scan);
      await loadHistory();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadHistory() async {
    history = await getHistoryUseCase.execute();
    notifyListeners();
  }

  Future<void> deleteScan(String id) async {
    await deleteScanUseCase.execute(id);
    await loadHistory();
  }
}

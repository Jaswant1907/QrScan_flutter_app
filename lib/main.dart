import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qscan_app_flutter/presentation/bloc/scanner/scanner_bloc.dart';
import 'package:qscan_app_flutter/presentation/model/history_item.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash_screen.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   final directory = await getApplicationDocumentsDirectory();
//   await Hive.initFlutter(directory.path);

//   Hive.registerAdapter(HistoryItemAdapter());

//   await Hive.deleteBoxFromDisk('historyBox');

//   await Hive.openBox<HistoryItem>('historyBox');

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (context) => ScannerBloc(cameraController: cameraController),)
//       ],
//       child: MaterialApp(
//         title: 'QScan App',
//         debugShowCheckedModeBanner: false,
//         theme: AppTheme.lightTheme,
//         darkTheme: AppTheme.darkTheme,
//         themeMode: ThemeMode.system,
//         home: const SplashScreen(),
//       ),
//     );
//   }
// }

import 'package:camera/camera.dart';

late CameraController _globalCameraController;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize camera here
  final cameras = await availableCameras();
  _globalCameraController = CameraController(
    cameras[0],
    ResolutionPreset.high,
    enableAudio: false,
  );
  await _globalCameraController.initialize();

  final directory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(directory.path);

  Hive.registerAdapter(HistoryItemAdapter());
  await Hive.deleteBoxFromDisk('historyBox');
  await Hive.openBox<HistoryItem>('historyBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ScannerBloc(
            cameraController: _globalCameraController,
            scanner: BarcodeScanner(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'QScan App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}

// Database initialization for mobile and desktop platforms
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:greenwise/data/repositories/tip_repository_sqlite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> initializeDatabase() async {
  // Check the ACTUAL runtime platform, not the simulated one
  // This is crucial for DevicePreview compatibility
  
  bool isDesktop = false;
  
  try {
    // Try to detect if we're on desktop
    // This will throw on web, which is fine
    isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  } catch (e) {
    // If Platform check fails, we're on web
    isDesktop = false;
  }
  
  // Initialize SQLite FFI ONLY for actual desktop platforms
  if (!kIsWeb && isDesktop) {
    try {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      debugPrint('✅ SQLite FFI initialized for desktop');
    } catch (e) {
      debugPrint('⚠️ SQLite FFI initialization failed: $e');
    }
  }
  
  // Populate tips database on all non-web platforms
  if (!kIsWeb) {
    try {
      await TipRepositorySqlite().populateIfEmpty();
      debugPrint('✅ Tips database populated');
    } catch (e) {
      debugPrint('⚠️ Error populating database: $e');
      debugPrint('   This is expected when running in DevicePreview on desktop');
      // Continue anyway - app will handle empty database gracefully
    }
  }
}

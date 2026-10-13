import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app/app.dart';
import 'app/injection.dart';
import 'core/database/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // En escritorio sqflite necesita el backend FFI; en Android/iOS no.
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final deps = AppDependencies(
    client: http.Client(),
    database: await AppDatabase.open(),
  );

  runApp(
    TiendaApp(
      createProductsCubit: deps.productsCubit,
      createFavoritesCubit: deps.favoritesCubit,
    ),
  );
}

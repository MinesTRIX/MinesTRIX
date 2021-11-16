/*
Copied from : https://gitlab.com/famedly/fluffychat/-/blob/main/lib/utils/matrix_sdk_extensions.dart/flutter_matrix_hive_database.dart
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:flutter/services.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:matrix/matrix.dart';
import 'package:minestrix/utils/platforms_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

class FlutterMatrixSembastDatabase extends MatrixSembastDatabase {
  FlutterMatrixSembastDatabase(
    String name, {
    SembastCodec? codec,
    String path = "./database.db",
    DatabaseFactory? dbFactory,
  }) : super(
          name,
          codec: codec,
          path: path,
          dbFactory: dbFactory,
        );

  static const String _cipherStorageKey = 'sembast_encryption_key';
  static const int _cipherStorageKeyLength = 512;

  static Future<FlutterMatrixSembastDatabase> databaseBuilder(
      Client client) async {
    Logs().d('Open Sembast...');
    SembastCodec? codec;
    try {
      // Workaround for secure storage is calling Platform.operatingSystem on web
      if (kIsWeb) throw MissingPluginException();

      const secureStorage = FlutterSecureStorage();
      final containsEncryptionKey =
          await secureStorage.containsKey(key: _cipherStorageKey);
      if (!containsEncryptionKey) {
        final key = SecureRandom(_cipherStorageKeyLength).base64;
        await secureStorage.write(
          key: _cipherStorageKey,
          value: key,
        );
      }

      // workaround for if we just wrote to the key and it still doesn't exist
      final rawEncryptionKey = await secureStorage.read(key: _cipherStorageKey);
      if (rawEncryptionKey == null) throw MissingPluginException();

      codec = getEncryptSembastCodec(password: rawEncryptionKey);
    } on MissingPluginException catch (_) {
      Logs().i('Sembast encryption is not supported on this platform');
    }

    final db = FlutterMatrixSembastDatabase(
      client.clientName,
      codec: codec,
      path: await _findDatabasePath(client),
      dbFactory: kIsWeb ? databaseFactoryWeb : databaseFactoryIo,
    );
    await db.open();
    Logs().d('Sembast is ready');
    return db;
  }

  static Future<String> _findDatabasePath(Client client) async {
    String path = client.clientName;
    if (!kIsWeb) {
      Directory directory;
      try {
        directory = await getApplicationSupportDirectory();
      } catch (_) {
        try {
          directory = await getLibraryDirectory();
        } catch (_) {
          directory = Directory.current;
        }
      }
      path = '${directory.path}/${client.clientName}.db';
    }
    print("db path : " + path);
    return path;
  }

  @override
  int get maxFileSize => supportsFileStoring ? 100 * 1024 * 1024 : 0;
  @override
  bool get supportsFileStoring => (PlatformInfos.isDesktop);

  Future<String> _getFileStoreDirectory() async {
    try {
      try {
        return (await getApplicationSupportDirectory()).path;
      } catch (_) {
        return (await getApplicationDocumentsDirectory()).path;
      }
    } catch (_) {
      return (await getDownloadsDirectory())!.path;
    }
  }

  @override
  Future<Uint8List?> getFile(Uri mxcUri) async {
    if (!supportsFileStoring) return null;
    final tempDirectory = await _getFileStoreDirectory();
    final file =
        File('$tempDirectory/${Uri.encodeComponent(mxcUri.toString())}');
    if (await file.exists() == false) return null;
    final bytes = await file.readAsBytes();
    return bytes;
  }

  @override
  Future storeFile(Uri mxcUri, Uint8List bytes, int time) async {
    if (!supportsFileStoring) return null;
    final tempDirectory = await _getFileStoreDirectory();
    final file =
        File('$tempDirectory/${Uri.encodeComponent(mxcUri.toString())}');
    if (await file.exists()) return;
    await file.writeAsBytes(bytes);
    return;
  }
}

class _EncryptEncoder extends Converter<Map<String, dynamic>, String> {
  final String key;
  final String signature;
  _EncryptEncoder(this.key, this.signature);

  @override
  String convert(Map<String, dynamic> input) {
    String encoded;
    switch (signature) {
      case "Salsa20":
        encoded = Encrypter(Salsa20(Key.fromUtf8(key)))
            .encrypt(json.encode(input), iv: IV.fromLength(8))
            .base64;
        break;
      case "AES":
        encoded = Encrypter(AES(Key.fromUtf8(key)))
            .encrypt(json.encode(input), iv: IV.fromLength(16))
            .base64;
        break;
      default:
        throw FormatException('invalid $signature');
    }
    return encoded;
  }
}

class _EncryptDecoder extends Converter<String, Map<String, dynamic>> {
  final String key;
  final String signature;
  _EncryptDecoder(this.key, this.signature);

  @override
  Map<String, dynamic> convert(String input) {
    dynamic decoded;
    switch (signature) {
      case "Salsa20":
        decoded = json.decode(Encrypter(Salsa20(Key.fromUtf8(key)))
            .decrypt64(input, iv: IV.fromLength(8)));
        break;
      case "AES":
        decoded = json.decode(Encrypter(AES(Key.fromUtf8(key)))
            .decrypt64(input, iv: IV.fromLength(16)));
        break;
      default:
        break;
    }
    if (decoded is Map) {
      return decoded.cast<String, dynamic>();
    }
    throw FormatException('invalid input $input');
  }
}

class _EncryptCodec extends Codec<Map<String, dynamic>, String> {
  final String signature;
  late _EncryptEncoder _encoder;
  late _EncryptDecoder _decoder;
  _EncryptCodec(String password, this.signature) {
    _encoder = _EncryptEncoder(password, signature);
    _decoder = _EncryptDecoder(password, signature);
  }

  @override
  Converter<String, Map<String, dynamic>> get decoder => _decoder;

  @override
  Converter<Map<String, dynamic>, String> get encoder => _encoder;
}

// Salsa20 (16 length key required) or AES (32 length key required)
SembastCodec getEncryptSembastCodec(
        {required String password, String signature = "Salsa20"}) =>
    SembastCodec(
        signature: signature, codec: _EncryptCodec(password, signature));

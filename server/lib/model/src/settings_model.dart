import 'dart:io';
import 'package:options_file/options_file.dart';
import 'package:logging/logging.dart';

class SettingsModel {
  static final Logger _log = new Logger('SettingsModel');
  OptionsFile _optionsFile = null;

  SettingsModel() {
    try {
      _optionsFile = new OptionsFile('server.options');
    } on FileSystemException catch (e) {
      _log.info("server.options not found, using all default settings", e);
    }
  }
  String get mongoConnectionString =>
      _getStringFromOptionFile("mongo", "mongodb://localhost:27017/dartfeed");

  String get movieDbApiKey => "";

  String get serverBindToAddress =>
      _getStringFromOptionFile("bind", InternetAddress.LOOPBACK_IP_V6.address);

  int get serverPort => _getIntFromOptionFile("port", 3278);

  int _getIntFromOptionFile(String option, int defaultValue) {
    if (_optionsFile != null) return _optionsFile.getInt(option, defaultValue);
    return defaultValue;
  }

  String _getStringFromOptionFile(String option, String defaultValue) {
    if (_optionsFile != null)
      return _optionsFile.getString(option, defaultValue);
    return defaultValue;
  }
}

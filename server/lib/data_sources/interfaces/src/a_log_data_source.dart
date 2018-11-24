import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartfeed/data/data.dart';
import 'package:option/option.dart';

abstract class ALogDataSource {
  static final Logger _log = new Logger('ALogDataSource');

  Future<Null> create(LogEntry data);
}

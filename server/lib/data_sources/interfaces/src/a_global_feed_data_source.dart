import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartfeed/data/data.dart';
import 'a_id_based_data_source.dart';

abstract class AGlobalFeedDataSource extends AIdBasedDataSource<GlobalFeed>  {
  static final Logger _log = new Logger('AGlobalFeedDataSource');

}

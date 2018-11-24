import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartfeed/data/data.dart';
import 'a_id_based_data_source.dart';

abstract class AFeedStoryDataSource extends AIdBasedDataSource<FeedStory>  {
  static final Logger _log = new Logger('AFeedStoryDataSource');

}

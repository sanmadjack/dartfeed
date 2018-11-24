import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartfeed/data/data.dart';
import 'package:dartfeed/data_sources/interfaces/interfaces.dart';
import 'a_mongo_id_data_source.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared/global.dart';
import 'package:shared/tools.dart';

class GlobalFeedMongoDataSource extends AMongoIdDataSource<GlobalFeed> with AGlobalFeedDataSource {
  static final Logger _log = new Logger('GlobalFeedMongoDataSource');

  @override
  GlobalFeed createObject(Map data) {
    GlobalFeed output = new GlobalFeed();
    ObjectId id = data[ID_FIELD];

    output.setId(new Id.fromBytes(id.id.byteList));
    output.text = data["text"];
    output.title = data["title"];
    output.htmlUrl = data["htmlUrl"];
    output.xmlUrl = data["xmlUrl"];
    output.version = data["version"];
    return output;
  }

  @override
  Future<DbCollection> getCollection(MongoDatabase con) =>
      con.getGlobalFeedsCollection();

  @override
  void updateMap(GlobalFeed feed, Map data) {
    data["text"] = feed.text;
    data["title"] = feed.title;
    data["htmlUrl"] = feed.htmlUrl;
    data["xmlUrl"] = feed.xmlUrl;
    data["version"] = feed.version;
  }
}

import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartfeed/data/data.dart';
import 'package:dartfeed/data_sources/interfaces/interfaces.dart';
import 'a_mongo_id_data_source.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared/global.dart';
import 'package:shared/tools.dart';

class FeedStoryMongoDataSource extends AMongoIdDataSource<FeedStory> with AFeedStoryDataSource {
  static final Logger _log = new Logger('FeedStoryMongoDataSource');

  @override
  FeedStory createObject(Map data) {
    FeedStory output = new FeedStory();
    ObjectId id = data[ID_FIELD];
    ObjectId feedId = data["feedId"];
    output.setId(new Id.fromBytes(id.id.byteList));
    output.setFeedId(new Id.fromBytes(feedId.id.byteList));
    output.title = data["title"];
    output.description = data["description"];
    output.link = data["link"];
    output.pubDate = data["pubDate"];
    return output;
  }

  @override
  Future<DbCollection> getCollection(MongoDatabase con) =>
      con.getFeedStoriesCollection();

  @override
  void updateMap(FeedStory story, Map data) {
    data["feedId"] = new ObjectId.fromBsonBinary(story.getFeedId.toBsonBinary());
    data["title"] = story.title;
    data["description"] = story.description;
    data["link"] = story.link;
    data["pubDate"] = story.pubDate;
  }
}

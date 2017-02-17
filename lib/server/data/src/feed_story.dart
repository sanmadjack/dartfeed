import 'id.dart';
import 'a_id_data.dart';

class FeedStory extends AIdData {
  Id _id;

  Id get getId => _id;
  void setId(Id value) {_id = value;}

  Id _feedId;

  Id get getFeedId => _feedId;
  void setFeedId(Id value) {_feedId = value;}

  String get uuid => _id.toString();
  void set uuid(String input) { _id = new Id.fromString(input);}

  String get feedUuid => _feedId.toString();
  void set feedUuid(String input) { _feedId = new Id.fromString(input);}

  String title, description, link, guid;

  DateTime pubDate;
}
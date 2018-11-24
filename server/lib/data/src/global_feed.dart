import 'id.dart';
import 'a_id_data.dart';

class GlobalFeed extends AIdData {
  Id _id;

  Id get getId => _id;

  void setId(Id value) {_id = value;}

  String get uuid => _id.toString();
  void set uuid(String input) { _id = new Id.fromString(input);}

  String title, text, htmlUrl, xmlUrl, version;
}
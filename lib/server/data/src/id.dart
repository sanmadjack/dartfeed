import 'package:bson/bson.dart';
import 'package:uuid/uuid.dart';

class Id  {
  final List<int> bytes;

  Id.fromBytes(this.bytes);

  Id.fromString(String input):
    bytes = new Uuid().parse(input);

  BsonBinary toBsonBinary() {
    return new BsonBinary.from(bytes);
  }
}
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartfeed/data/data.dart';
import 'package:option/option.dart';
import 'package:uuid/uuid.dart';

abstract class AIdBasedDataSource<T extends AIdData> extends Object {
  static final Logger _log = new Logger('AIdModel');

  Future<List<T>> getAll();
  Future<Option<T>> getById(Id id);
  Future<Id> write(T t, [Id id = null]);
  Future<Null> deleteByID(Id id);
  Future<bool> existsByID(Id id);
  //Future<List<T>> search(String query);
  Future<List<T>> getByIds(List<Id> ids);

}

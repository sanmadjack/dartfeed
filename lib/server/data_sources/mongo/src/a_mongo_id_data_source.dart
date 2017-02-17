import 'dart:async';
import 'package:dartfeed/global.dart';
import 'package:dartfeed/tools.dart';
import 'package:dartfeed/server/data/data.dart';
import 'package:dartfeed/server/data_sources/interfaces/interfaces.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:option/option.dart';
import 'package:uuid/uuid.dart';
import 'a_mongo_object_data_source.dart';
import 'package:meta/meta.dart';

export 'a_mongo_object_data_source.dart';

const String ID_FIELD = "_id";

abstract class AMongoIdDataSource<T extends AIdData>
    extends AMongoObjectDataSource<T> with AIdBasedDataSource<T> {

  dynamic _createSelector(Id id) => where.eq(ID_FIELD, new ObjectId.fromBsonBinary(new BsonBinary.from(id.bytes)));

  @override
  Future deleteByID(Id id) => deleteFromDb(_createSelector(id));

  @override
  Future<bool> existsByID(Id id) => super.exists(_createSelector(id));

  Future<List<T>> getAll({String sortField: ID_FIELD}) => getFromDb(where.sortBy(sortField));

  Future<PaginatedData<T>> getPaginated(
          {String sortField: ID_FIELD,
          int offset: 0,
          int limit: PAGINATED_DATA_LIMIT}) => getPaginatedFromDb(
          where.sortBy(sortField),
          offset: offset, limit: limit);

//  Future<List<IdNamePair>> getAllIdsAndNames(
//          {String sortField: ID_FIELD}) =>
//      getIdsAndNames(sortField: sortField);

//  Future<List<IdNamePair>> getIdsAndNames(
//      {SelectorBuilder selector, String sortField: ID_FIELD}) async {
//    return await collectionWrapper((DbCollection collection) async {
//      if (selector == null) selector = where;
//
//      selector.sortBy(sortField);
//
//      final List<dynamic> results = await collection.find(selector).toList();
//
//      final IdNameList<IdNamePair> output = new IdNameList<IdNamePair>();
//
//      for (Map<String, dynamic> result in results) {
//        output.add(new IdNamePair.from(result[ID_FIELD], result["name"]));
//      }
//
//      return output;
//    });
//  }

//  Future<PaginatedIdNameData<IdNamePair>> getPaginatedIdsAndNames(
//      {SelectorBuilder selector,
//      String sortField: ID_FIELD,
//      int offset: 0,
//      int limit: 10}) async {
//    return await collectionWrapper((DbCollection collection) async {
//      final int count = await collection.count();
//
//      if (selector == null) selector = where;
//
//      final List<dynamic> results = await collection
//          .find(selector.sortBy(sortField).limit(limit).skip(offset))
//          .toList();
//
//      final PaginatedIdNameData<IdNamePair> output =
//          new PaginatedIdNameData<IdNamePair>();
//      output.startIndex = offset;
//      output.limit = limit;
//      output.totalCount = count;
//
//      for (Map<String, dynamic> result in results) {
//        output.data.add(new IdNamePair.from(result[ID_FIELD], result["name"]));
//      }
//
//      return output;
//    });
//  }

  @override
  Future<Option<T>> getById(Id id) =>
      getForOneFromDb(_createSelector(id));

  Future<List<T>> getByIds(List<Id> ids) async {
    if (ids == null) return new List<T>();

    SelectorBuilder query = null;

    for (Id id in ids) {
      SelectorBuilder sb = _createSelector(id);
      if (query == null) {
        query = sb;
      } else {
        query.or(sb);
      }
    }

    List<T> results = await getFromDb(query);

    return results;
  }

  @override
  Future<Id> write(T object, [Id id = null]) async {
    if (id==null) {
      ObjectId objId = await insertIntoDb(object);
      return new Id.fromBytes(objId.id.byteList);
    } else {
      await updateToDb(where.eq(ID_FIELD, id), object);
      return id;
    }
  }


//  @protected
//  Future<IdNameList<T>> getIdNameListFromDb(dynamic selector) async =>
//      new IdNameList<T>.copy(await getFromDb(selector));
//

}

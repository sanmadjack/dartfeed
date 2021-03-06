import 'dart:async';
import 'package:shared/global.dart';
import 'package:shared/tools.dart';
import 'package:dartfeed/data/data.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:option/option.dart';
import 'package:meta/meta.dart';
import 'a_mongo_data_source.dart';
import 'constants.dart';

export 'a_mongo_data_source.dart';

abstract class AMongoObjectDataSource<T> extends AMongoDataSource {
  @protected
  Future<List<T>> searchAndSort(String query,
      {SelectorBuilder selector, String sortBy}) async {
    final SelectorBuilder searchSelector =
        _prepareTextSearch(query, selector: selector);
    return await getFromDb(searchSelector);
  }

  Future<PaginatedData<T>> searchPaginated(String query,
      {SelectorBuilder selector,
      int offset: 0,
      int limit: PAGINATED_DATA_LIMIT}) async {
    final SelectorBuilder searchSelector =
        _prepareTextSearch(query, selector: selector);
    return await getPaginatedFromDb(searchSelector);
  }

  Map<String, dynamic> _createMap(T object) {
    final Map<String, dynamic> data = <String, dynamic>{};
    updateMap(object, data);
    return data;
  }

  @protected
  T createObject(Map<String, dynamic> data);

  @protected
  @override
  Future<DbCollection> getCollection(MongoDatabase con);

  @protected
  Future<Option<T>> getForOneFromDb(SelectorBuilder selector) async {
    final List<T> results = await getFromDb(selector.limit(1));
    if (results.length == 0) {
      return new None<T>();
    }
    return new Some<T>(results.first);
  }

  @protected
  Future<List<T>> getFromDb(dynamic selector) async {
    final List<dynamic> results = await genericFind(selector);
    final List<T> output = new List<T>();
    for (dynamic result in results) {
      output.add(createObject(result));
    }
    return output;
  }

  @protected
  Future<PaginatedData<T>> getPaginatedFromDb(SelectorBuilder selector,
      {int offset: 0,
      int limit: PAGINATED_DATA_LIMIT,
      String sortField}) async {
    final PaginatedData<T> output = new PaginatedData<T>();
    output.totalCount = await genericCount(selector);
    output.limit = limit;
    output.startIndex = offset;

    if (selector == null) selector == where;
    if (!StringTools.isNullOrWhitespace(sortField)) selector.sortBy(sortField);

    selector.limit(limit).skip(offset);

    output.data.addAll(await getFromDb(selector));
    return output;
  }

  @protected
  Future<ObjectId> insertIntoDb(T item) async {
    return await collectionWrapper((DbCollection collection) async {
      final Map<String, dynamic> data = _createMap(item);
      ObjectId newId = new ObjectId();
      data["_id"] = newId;
      await collection.insert(data);
      return newId;
    });
  }

  SelectorBuilder _prepareTextSearch(String query,
      {SelectorBuilder selector, String sortBy}) {
    SelectorBuilder searchSelector =
        where.eq(TEXT_COMMAND, {SEARCH_COMMAND: query});
    if (selector != null) searchSelector = searchSelector.and(selector);
    if (!StringTools.isNullOrWhitespace(sortBy)) {
      searchSelector = searchSelector.sortBy(sortBy);
    } else {
      searchSelector =
          searchSelector.metaTextScore("score").sortByMetaTextScore("score");
    }
    return searchSelector;
  }

  @protected
  void updateMap(T object, Map<String, dynamic> data);

  @protected
  Future<Null> updateToDb(dynamic selector, T item) async {
    return await collectionWrapper((DbCollection collection) async {
      final Map<String, dynamic> data = await collection.findOne(selector);
      if (data == null)
        throw new InvalidInputException("Object to update not found");
      final dynamic originalId = data['_id'];
      updateMap(item, data);
      await collection.save(data);
      if (data['_id'] != originalId) await collection.remove(selector);
    });
  }
}

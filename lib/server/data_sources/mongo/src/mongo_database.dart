import 'dart:async';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:connection_pool/connection_pool.dart';
import 'package:dartfeed/server/model/model.dart' as model;
import 'mongo_db_connection_pool.dart';

class MongoDatabase {
  static final Logger _log = new Logger('_MongoDatabase');
  static MongoDbConnectionPool _pool;

  static const String _globalFeedsCollection = "globalFeeds";
  static const String _feedStoriesCollection = "feedStories";
  static const String _usersCollection = "users";
  static const String _userFoldersCollection = "userFolders";
  static const String _userFeedsCollection = "userFeeds";

  ManagedConnection<Db> con;

  bool released = false;

  MongoDatabase(this.con);

  DbCollection _getCollection(String name) {
    _checkConnection();
    return con.conn.collection(name);
  }

  Future<DbCollection> getGlobalFeedsCollection() async {
    final dynamic output = _getCollection(_globalFeedsCollection);
    await con.conn.createIndex(_globalFeedsCollection,
        key: "xmlUrl",
        unique: true,
        sparse: true,
        name: "GlobalFeedUrlIndex");
    return output;
  }

  Future<DbCollection> getFeedStoriesCollection() async {
    final dynamic output = _getCollection(_feedStoriesCollection);
    await con.conn.createIndex(_feedStoriesCollection,
        key: "feedId",
        unique: false,
        sparse: true,
        name: "FeedStoriesFeedIndex");
    return output;
  }

  Future<DbCollection> getUserFoldersCollection() async {
    return _getCollection(_userFoldersCollection);
  }

  Future<DbCollection> getUserFeedsCollection() async {
    return _getCollection(_userFeedsCollection);
  }

  Future<DbCollection> getUsersCollection() async {
    return _getCollection(_usersCollection);
  }

  void release({bool dispose: false}) {
    if (released) return;
    if (dispose) {
      _pool.releaseConnection(con, markAsInvalid: true);
    } else {
      _pool.releaseConnection(con);
    }
    con = null;
    released = true;
  }

  void _checkConnection() {
    if (released) throw new Exception("Connection has already been released");
  }

  static Future<MongoDatabase> getConnection() async {
    if (_pool == null) {
      _pool =
          new MongoDbConnectionPool(model.settings.mongoConnectionString, 3);
    }

    ManagedConnection con = await _pool.getConnection();
    Db db = con.conn;

    int i = 0;
    while (db == null || db.state != State.OPEN) {
      if (i > 5) {
        throw new Exception(
            "Too many attempts to fetch a connection from the pool");
      }
      if (con != null) {
        _log.info(
            "Mongo database connection has issue, returning to pool and re-fetching");
        _pool.releaseConnection(con, markAsInvalid: true);
      }
      con = await _pool.getConnection();
      db = con.conn;
      i++;
    }

    return new MongoDatabase(con);
  }
}

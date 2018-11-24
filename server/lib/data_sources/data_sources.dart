import 'package:di/di.dart';
import 'mongo/mongo.dart';
import 'interfaces/interfaces.dart';
import 'mongo/src/mongo_db_connection_pool.dart';

AGlobalFeedDataSource globalFeeds = new GlobalFeedMongoDataSource();

ModuleInjector createDataSourceModuleInjector(String connectionString) {
  final Module module = new Module()
    ..bind(AGlobalFeedDataSource, toImplementation: GlobalFeedMongoDataSource)
    ..bind(ALogDataSource, toImplementation:  MongoLogDataSource)
    ..bind(MongoDbConnectionPool,
        toFactory: () => new MongoDbConnectionPool(connectionString));

  return new ModuleInjector(<Module>[module]);
}

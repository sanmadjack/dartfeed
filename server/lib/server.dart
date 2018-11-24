import 'dart:async';
import 'package:dartfeed/model/model.dart' as model;
import 'package:di/di.dart';
import 'package:logging/logging.dart';
import 'package:di/di.dart';
import 'src/db_logging_handler.dart';
import 'package:rpc/rpc.dart';
import 'package:shelf_rpc/shelf_rpc.dart' as shelf_rpc;
import 'package:shared/global.dart';
import 'package:shared/tools.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:http_server/http_server.dart';

export 'src/exceptions/setup_disabled_exception.dart';
export 'src/exceptions/setup_required_exception.dart';
export 'src/exceptions/not_authorized_exception.dart';
export 'src/db_logging_handler.dart';


ModuleInjector getServerModuleInjector(String connectionString) {
    final Module module = new Module()
      ..bind(Server)
      ..bind(DbLoggingHandler);

    final ModuleInjector parent =
    model.createModelModuleInjector(connectionString);

    final ModuleInjector injector = new ModuleInjector([module], parent);

    return injector;
}

class Server {
  final Logger _log = new Logger('Server');



  String instanceUuid;
  String connectionString;
  ModuleInjector injector;

  final ApiServer _apiServer =
  new ApiServer(apiPrefix: apiPrefix, prettyPrint: true);


  static Server createInstance(String connectionString, {String instanceUuid}) {
    ModuleInjector injector = getServerModuleInjector(connectionString);

    final DbLoggingHandler dbLoggingHandler = injector.get(DbLoggingHandler);
    Logger.root.onRecord.listen(dbLoggingHandler);

    final Server server = injector.get(Server);
    server.instanceUuid = instanceUuid ?? generateUuid();
    server.connectionString = connectionString;
    server.injector = injector;

    return server;
  }

  HttpServer _server;

  dynamic start(String bindIp, int port) async {


    _apiServer.addApi(new FeedAPI());
    _apiServer.enableDiscoveryApi();

    final shelf.Handler apiHandler = shelf_rpc.createRpcHandler(_apiServer);


    var handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests())
        .addMiddleware(exceptionHandler())
        .addHandler(apiHandler);

    final HttpServer _server = await io.serve(handler, '0.0.0.0', port).then((server) {
      print('Serving at http://${server.address.host}:${server.port}');
    });

  }

}



class RefreshService {
  bool _stop = false;



  Future RunService() async {
    while(!_stop) {
      await model.feeds.refreshNextFeedStories();
    }
  }

  void StopService() {
    _stop = true;
  }

}
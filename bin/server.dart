// Copyright (c) 2017, testuset. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:async';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:logging/logging.dart';
import 'package:logging_handlers/server_logging_handlers.dart' as serverLogging;
import 'package:shelf_rpc/shelf_rpc.dart' as shelf_rpc;
import 'package:rpc/rpc.dart';
import 'package:dartfeed/global.dart';
import 'package:dartfeed/server/api/api.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_exception_handler/shelf_exception_handler.dart';

Future main(List<String> args) async {
  var parser = new ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '3333');

  var result = parser.parse(args);

  var port = int.parse(result['port'], onError: (val) {
    stdout.writeln('Could not parse port value "$val" into a number.');
    exit(1);
  });

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(new serverLogging.LogPrintHandler());
  final Logger _log = new Logger('main');


  final ApiServer _apiServer =
    new ApiServer(apiPrefix: apiPrefix, prettyPrint: true);
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

shelf.Response _echoRequest(shelf.Request request) {
  return new shelf.Response.ok('Request for "${request.url}"');
}

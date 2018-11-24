
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:rpc/rpc.dart';
import '../../api.dart';
import '../resource_base.dart';
import 'package:dartfeed/model/model.dart' as model;

class FeedResource extends ResourceBase {
  static final Logger _log = new Logger('FeedResource');

  @override
  Logger get childLogger => _log;

  static const apiPath = "feeds";

  @ApiMethod(method: 'GET', path: '${apiPath}/')
  Future<StringResponse> getFeeds() async {
    return new StringResponse("test");
  }

  @ApiMethod(method: 'PUT', path: '$apiPath/import/')
  Future<VoidMessage>importFeeds(MediaMessage file)  => catchExceptionsAwait(() async {
    await model.feeds.ImportFeeds(file.bytes);
  });
}
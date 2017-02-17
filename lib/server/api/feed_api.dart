import 'package:rpc/rpc.dart';

import 'package:dartfeed/global.dart';
import 'src/resources/feed_resource.dart';

export 'src/responses/string_response.dart';


@ApiClass(
    version: feedApiVersion, name: feedApiName, description: 'Feed REST API')
class FeedAPI {

  @ApiResource()
  final FeedResource feeds = new FeedResource();

  FeedAPI();
}
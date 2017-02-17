import 'package:dartfeed/global.dart';
import '../client.dart';
import 'package:http/browser_client.dart';
import 'src/feed.dart';

export 'package:_discoveryapis_commons/_discoveryapis_commons.dart'
    show DetailedApiRequestError, ApiRequestErrorDetail;


export 'src/feed.dart'
    show
    MediaMessage;

FeedApi _feeds;
FeedApi get feeds {
  if (_feeds == null) {
    _feeds = new FeedApi(new BrowserClient(),
        rootUrl: getServerRoot(), servicePath: feedApiPath);
  }
  return _feeds;
}

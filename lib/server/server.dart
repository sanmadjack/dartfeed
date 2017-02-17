import 'dart:async';
import 'package:dartfeed/server/model/model.dart' as model;

export 'src/exceptions/setup_disabled_exception.dart';
export 'src/exceptions/setup_required_exception.dart';
export 'src/exceptions/not_authorized_exception.dart';


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
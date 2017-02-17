import 'dart:async';
import 'dart:convert';
import 'package:dart_feed/dart_feed.dart';
import 'package:dartfeed/global.dart';
import 'package:logging/logging.dart';
import 'package:dartfeed/opml/opml.dart' as opml;
import 'package:dartfeed/tools.dart';
import 'package:dartfeed/server/data/data.dart';
import 'package:dartfeed/server/data_sources/data_sources.dart' as data_source;

class FeedModel {
  static final Logger _log = new Logger('FeedModel');

  Future ImportFeeds(List<int> data) async {
    try {
      String stringData = UTF8.decode(data);
      opml.OpmlDocument doc = opml.parse(stringData);

      await _InternalFeedImport(doc.body.children);
    } on opml.OpmlFormatException catch (e,st) {
      throw new InvalidInputException(e.message);
    }
  }

  Future _InternalFeedImport(Iterable<opml.OpmlOutlineNode> nodes) async {
    for(opml.OpmlOutlineNode node in nodes) {
      String title = node.getProperty("title");
      String text = node.getProperty("text");

      String htmlUrl = node.getProperty("htmlUrl");
      String type = node.getProperty("type");
      String version = node.getProperty("version");
      String xmlUrl = node.getProperty("xmlUrl");

      switch(type.toLowerCase()) {
        case "":
          // This is probably a folder
          if(node.children.isNotEmpty) {
            await _InternalFeedImport(node.children);
          }
          break;
        case "rss":
          GlobalFeed feed = new GlobalFeed();
          feed.title = title;
          feed.text = text;
          feed.htmlUrl = htmlUrl;
          feed.xmlUrl = xmlUrl;
          feed.version = version;
          await data_source.globalFeeds.write(feed);
          break;
      }
    }

  }

  Future refreshNextFeedStories() {
    try {

      Feed feed = Feed.fromUri();

    } catch (e,st) {
      _log.severe("Error while refreshing news feed story", e, st);
    }
  }
}
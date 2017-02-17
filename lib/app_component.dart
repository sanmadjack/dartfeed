// Copyright (c) 2017, testuset. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:async';
import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import 'package:dartfeed/client/api/api.dart' as api;
import 'package:dartfeed/hello_dialog/hello_dialog.dart';
import 'package:mime/mime.dart' as mime;

@Component(
  selector: 'my-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [materialDirectives, HelloDialog],
  providers: const [materialProviders],
)
class AppComponent {
  // Nothing here yet. All logic is in HelloDialog.

  Future uploadFile() async {
    InputElement input = document.querySelector("#fileUpload");

    if (input.files.length == 0) return;
      File file = input.files[0];

      FileReader reader = new FileReader();
      reader.readAsArrayBuffer(file);
      await for (dynamic fileEvent in reader.onLoad) {
          api.MediaMessage msg = new api.MediaMessage();
          msg.bytes = reader.result;

          msg.contentType = mime.lookupMimeType(file.name,
              headerBytes: msg.bytes.sublist(0, 10));

          await api.feeds.feeds.importFeeds(msg);

          window.alert("Upload completed");
      }
  }
}

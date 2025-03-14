// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:async';

import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  late int port;
  setUpAll(() async {
    final channel =
        spawnHybridUri(Uri(path: '/test/stub_server.dart'), stayAlive: true);
    port = (await channel.stream.first as num).toInt();
  });

  test('#send a StreamedRequest', () async {
    var client = BrowserClient();
    var request = http.StreamedRequest('POST', echoUrl.replace(port: port));

    var responseFuture = client.send(request);
    request.sink.add('{"hello": "world"}'.codeUnits);
    unawaited(request.sink.close());

    var response = await responseFuture;

    var bytesString = await response.stream.bytesToString();

    client.close();

    expect(bytesString,
        parse(allOf(containsPair('body', '{"hello": "world"}'.codeUnits))));
  });

  test('#send with an invalid URL', () {
    var client = BrowserClient();
    var url = Uri.http('http.invalid', '');
    var request = http.StreamedRequest('POST', url);

    expect(client.send(request), throwsClientException());

    request.sink.add('{"hello": "world"}'.codeUnits);
    request.sink.close();
  });
}

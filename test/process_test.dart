import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'utils/docker_utils.dart' as dockerUtils;

void main() {
  group('Test running processes', () {
    test('Hello', () async {
      String logFilePath = 'logfile.txt';

      // Creating a file object
      File logFile = File(logFilePath);
      await runZonedGuarded(
          () async {
            String imageName =
                'ghcr.io/mittons/dr07:latest'; // Replace with image name
            // 'ghcr.io/mittons/dockreg26:1.0'; // Replace with image name
            int hostPort = 3000;
            int containerPort = 8003;
            String containerId = await dockerUtils.startContainer(
                imageName, hostPort, containerPort);
            print('Started Container ID: $containerId');

            await Future.delayed(Duration(seconds: 3));

            await _playWithHttp();

            await Future.delayed(Duration(seconds: 10));

            // After your testing or other operations
            await dockerUtils.stopContainer(containerId);
            print('Container stopped.');
          },
          (error, stack) {},
          zoneSpecification:
              ZoneSpecification(print: (self, parent, zone, line) {
            logFile.writeAsStringSync("${line}\n", mode: FileMode.append);
            parent.print(zone, line);
          }));
      //
    });
  });
}

Future<void> _playWithHttp() async {
  final response =
      await http.get(Uri.parse("http://localhost:3000/WeatherForecast"));

  final dynamic jsonResponse = json.decode(response.body);

  var date = jsonResponse[0]['date'];
  var tempc = jsonResponse[0]['temperatureC'];
  var summary = jsonResponse[0]['summary'];

  print(
      "On ${date} it was a lovely ${tempc} degrees C and the weather was ${summary}!");
}

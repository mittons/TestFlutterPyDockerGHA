import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'package:http/http.dart' as http;

void main() {
  group('Test running processes', () {
    test('Hello', () async {
      String logFilePath = 'logfile.txt';

      // Creating a file object
      File logFile = File(logFilePath);
      await runZonedGuarded(
          () async {
            String imageName =
                'ghcr.io/mittons/dockreg26:1.0'; // Replace with image name
            String containerId = await startContainer(imageName);
            print('Started Container ID: $containerId');

            await Future.delayed(Duration(seconds: 3));

            await _playWithHttp();

            await Future.delayed(Duration(seconds: 10));

            // After your testing or other operations
            await stopContainer(containerId);
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

Future<String> startContainer(String imageName) async {
  String containerId = '';

  var process = await Process.start(
      'python', ['./scripts/hello_python.py', 'start', imageName]);

  await for (var line
      in process.stdout.transform(Utf8Decoder()).transform(LineSplitter())) {
    print('Python stdout: $line');
    containerId =
        line.trim(); // Assuming container ID is the last line of stdout
  }

  await for (var line
      in process.stderr.transform(Utf8Decoder()).transform(LineSplitter())) {
    print('Python stderr: $line');
  }

  return containerId;
}

Future<void> stopContainer(String containerId) async {
  var process = await Process.start(
      'python', ['./scripts/hello_python.py', 'stop', containerId]);

  await for (var line
      in process.stdout.transform(Utf8Decoder()).transform(LineSplitter())) {
    print('Python stdout: $line');
  }

  await for (var line
      in process.stderr.transform(Utf8Decoder()).transform(LineSplitter())) {
    print('Python stderr: $line');
  }
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

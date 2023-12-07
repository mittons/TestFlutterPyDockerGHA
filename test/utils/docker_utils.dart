import 'dart:io';
import 'dart:convert';

Future<String> startContainer(
    String imageName, int hostPort, int containerPort) async {
  String containerId = '';

  var process = await Process.start('python', [
    './scripts/hello_python.py',
    'start',
    imageName,
    hostPort.toString(),
    containerPort.toString()
  ]);

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

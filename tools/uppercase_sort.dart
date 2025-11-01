import 'dart:io';

void main(List<String> args) {
  final filePath = args.isNotEmpty ? args[0] : './assets/guesses.txt';
  final file = File(filePath);

  if (!file.existsSync()) {
    stderr.writeln('File not found: $filePath');
    exit(2);
  }

  // Read lines, convert to uppercase, sort, remove duplicates
  final lines = file.readAsLinesSync().map((l) => l.toUpperCase()).toList();

  lines.sort();
  final uniqueSorted = <String>[];
  for (var i = 0; i < lines.length; i++) {
    if (i == 0 || lines[i] != lines[i - 1]) uniqueSorted.add(lines[i]);
  }

  // Write back atomically via temp file
  final tmp = File('${filePath}.tmp');
  tmp.writeAsStringSync(
    uniqueSorted.join('\n') + (uniqueSorted.isNotEmpty ? '\n' : ''),
  );
  tmp.renameSync(filePath);
}

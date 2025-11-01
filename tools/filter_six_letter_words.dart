import 'dart:io';

void main(List<String> args) {
  if (args.contains('--help') || args.contains('-h')) {
    print('''
Usage:
  dart run filter_six_letter_words.dart <file>
  dart run filter_six_letter_words.dart --help

Arguments:
  <file>      Path to the file to process (required)

Options:
  --help, -h  Show this help message and exit

Description:
  Reads a text file and removes any lines that aren't exactly 6 characters long.
  Writes the filtered result back to the file atomically.
''');
    exit(0);
  }

  if (args.isEmpty) {
    stderr.writeln('Error: file path argument is required');
    stderr.writeln('Run with --help for usage information');
    exit(1);
  }

  final filePath = args[0];
  final file = File(filePath);

  if (!file.existsSync()) {
    stderr.writeln('File not found: $filePath');
    exit(2);
  }

  // Read lines and filter to only those with exactly 6 characters
  final lines = file
      .readAsLinesSync()
      .where((line) => line.length == 6)
      .toList();

  // Write back atomically via temp file
  final tmp = File('${filePath}.tmp');
  tmp.writeAsStringSync(lines.join('\n') + (lines.isNotEmpty ? '\n' : ''));
  tmp.renameSync(filePath);

  print('Filtered file: $filePath (${lines.length} lines remaining)');
}

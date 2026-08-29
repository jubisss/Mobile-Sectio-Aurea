import 'dart:io';

void main() {
  final file = File('lib/screens/tabs/revisao_tab.dart');
  final content = file.readAsStringSync();
  final lines = content.split('\n');
  
  List<String> stack = [];
  
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    int lineNum = i + 1;
    for (int j = 0; j < line.length; j++) {
      final char = line[j];
      if (char == '{') {
        stack.add('{$lineNum:${j+1}');
        if (lineNum >= 220 && lineNum <= 380) {
          print('Line $lineNum, char ${j+1}: Open brace. Current stack size: ${stack.length}. Stack: $stack');
        }
      } else if (char == '}') {
        if (stack.isEmpty) {
          print('Line $lineNum, char ${j+1}: Unexpected close brace!');
        } else {
          final popped = stack.removeLast();
          if (lineNum >= 220 && lineNum <= 380) {
            print('Line $lineNum, char ${j+1}: Close brace matching $popped. Current stack size: ${stack.length}. Stack: $stack');
          }
        }
      }
    }
  }
}

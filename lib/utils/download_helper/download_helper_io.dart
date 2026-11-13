import 'dart:io';

void downloadFile(String path, String filename) {
  final cleanPath = path.startsWith('/') ? path.substring(1) : path;
  final url = 'https://renuka.jayaramdhungana.com.np/$cleanPath';
  if (Platform.isWindows) {
    Process.run('cmd', ['/c', 'start', '', url]);
  } else if (Platform.isLinux) {
    Process.run('xdg-open', [url]);
  } else if (Platform.isMacOS) {
    Process.run('open', [url]);
  }
}


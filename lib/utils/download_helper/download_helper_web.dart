import 'dart:html' as html;

void downloadFile(String path, String filename) {
  final anchor = html.AnchorElement(href: path)
    ..setAttribute('download', filename)
    ..target = '_blank';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}


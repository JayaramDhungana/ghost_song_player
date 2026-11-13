import 'download_helper_stub.dart'
    if (dart.library.html) 'download_helper_web.dart'
    if (dart.library.io) 'download_helper_io.dart';

void triggerAppDownload(String path, String filename) {
  downloadFile(path, filename);
}


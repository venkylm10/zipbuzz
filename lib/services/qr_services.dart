import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';

class QrServices {
  static void shareEventQrCode(String link, EventModel event) async {
    final image = await QrPainter(
      data: link,
      version: QrVersions.auto,
      gapless: false,
      embeddedImageStyle: const QrEmbeddedImageStyle(
        size: Size(120, 120),
        color: Colors.white,
      ),
      eyeStyle: const QrEyeStyle(
        color: Colors.white,
        eyeShape: QrEyeShape.square,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        color: Colors.white,
        dataModuleShape: QrDataModuleShape.square,
      ),
    ).toImage(300);

    final directory = await getExternalStorageDirectory();
    final filePath = '${directory!.path}/qr_code.png';

    File(filePath).writeAsBytesSync(
        (await image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List());

    Share.shareXFiles([XFile(filePath)],
        text:
            "Scan the QR to find more details on ZipBuzz App\nEvent: ${event.title}\nAbout: ${event.about}\nHost: ${event.hostName}\nDate: ${event.date.substring(0, 10)}\nStart Time: ${event.startTime}\nEnd Time: ${event.endTime}\nLocation: ${event.location}");
  }

  static void showQRImage(String link, EventModel event) async {
    print(link);
    final image = await QrPainter(
      data: link,
      version: QrVersions.auto,
      gapless: false,
      embeddedImageStyle: const QrEmbeddedImageStyle(
        size: Size(120, 120),
        color: Colors.white,
      ),
      eyeStyle: const QrEyeStyle(
        color: Colors.white,
        eyeShape: QrEyeShape.square,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        color: Colors.white,
        dataModuleShape: QrDataModuleShape.circle,
      ),
    ).toImage(300);

    final directory = await getExternalStorageDirectory();
    final filePath = '${directory!.path}/qr_code.png';

    File(filePath).writeAsBytesSync(
        (await image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List());

    showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: true,
        builder: (context) {
          final width = MediaQuery.of(context).size.width;
          return AlertDialog(
            backgroundColor: AppColors.primaryColor.withOpacity(0.75),
            surfaceTintColor: Colors.transparent,
            content: Container(
              height: width * 0.75,
              width: width * 0.75,
              constraints: const BoxConstraints(
                maxHeight: 300,
                maxWidth: 300,
              ),
              child: Image.file(
                File(filePath),
                fit: BoxFit.contain,
              ),
            ),
          );
        });
  }
}

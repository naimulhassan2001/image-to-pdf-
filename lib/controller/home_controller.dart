import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';


import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:external_path/external_path.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:media_scanner/media_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeController extends GetxController {
  List<XFile> imagePaths = [];
  late double progressValue = 0;
  late bool isProgress = false;
  late bool isExporting = false;
  late int convertedImage = 0;
  bool _isPickingImage = false;

  static HomeController get instance => Get.put(HomeController());

  void convertImage() async {
    isExporting = true;
    isProgress = true;
    update();

    final pathToSave = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOCUMENTS);

    final pdf = pw.Document();

    for (final imagePath in imagePaths) {
      final imageBytes = await File(imagePath.path).readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image != null) {
        final pdfImage = pw.MemoryImage(imageBytes);
        pdf.addPage(
          pw.Page(build: (pw.Context context) {
            return pw.Center(child: pw.Image(pdfImage));
          }),
        );
      }

      convertedImage++;
      progressValue = convertedImage / imagePaths.length;
      update();
    }

    // Generate a unique file name
    String fileName = 'NewPdf';
    String fileExtension = '.pdf';
    String fullPath = '$pathToSave/$fileName$fileExtension';
    int counter = 1;

    while (await File(fullPath).exists()) {
      fullPath = '$pathToSave/$fileName$counter$fileExtension';
      counter++;
    }

    // Save the PDF with the unique file name
    final outputFile = File(fullPath);
    await outputFile.writeAsBytes(await pdf.save());

    // Notify the media scanner about the new file
    MediaScanner.loadMedia(path: outputFile.path);

    imagePaths.clear();
    progressValue = 0;
    isProgress = false;
    isExporting = false;
    convertedImage = 0;
    _isPickingImage = false;
    update();
    Get.snackbar("pdf Download", "pdf download successfully");
  }

  Future<PermissionStatus> storagePermissionStatus() async {

    PermissionStatus storagePermissionStatus = await Permission.storage.status;


    if (!storagePermissionStatus.isGranted) {
      await Permission.storage.request();
    }

    if (await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }

    storagePermissionStatus = await Permission.storage.status;
    PermissionStatus manageExternalStorageStatus =
        await Permission.manageExternalStorage.status;

    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt >= 30) { // Android 11 (API level 30) or above
        if (storagePermissionStatus.isGranted &&
            manageExternalStorageStatus.isGranted) {
          return PermissionStatus.granted;
        } else {
          return PermissionStatus.denied;
        }
      } else {
        if (storagePermissionStatus.isGranted) {
          return PermissionStatus.granted;
        } else {
          return PermissionStatus.denied;
        }
      }
    }

    return PermissionStatus.denied;

  }

  void pickGalleryImage() async {
    if (_isPickingImage) return;

    _isPickingImage = true;
    isExporting = true;
    update();
    PermissionStatus status = await storagePermissionStatus();

    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        imagePaths.addAll(images);

        print(imagePaths.length);
      }
      update();
    }

    _isPickingImage = false;
  }
}

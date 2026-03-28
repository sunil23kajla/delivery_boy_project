import 'dart:io';

void main() {
  final srcDir = Directory('lib/presentation/screens/delivery_flow/widgets');
  final dstDir =
      Directory('lib/presentation/screens/home/quick/delivery/widgets');

  if (!dstDir.existsSync()) {
    dstDir.createSync(recursive: true);
  }

  final files = srcDir.listSync().whereType<File>().toList();
  for (var file in files) {
    if (!file.path.endsWith('.dart')) continue;

    final fileName = file.uri.pathSegments.last;
    final newFileName = fileName.replaceAll('delivery_', 'quick_fvd_');
    final newFile = File('${dstDir.path}/$newFileName');

    String content = file.readAsStringSync();

    // Replace imports
    content = content.replaceAll("import '../delivery_flow_controller.dart';",
        "import '../../quick_flow_controller.dart';");
    content = content.replaceAll(
        "import '../../../../core/", "import 'package:delivery_boy/core/");

    // Replace Controller name
    content =
        content.replaceAll("DeliveryFlowController", "QuickFlowController");

    // Replace Method/Property names to match QuickFlowController's fvd-prefixed variables
    content =
        content.replaceAll("controller.isScanDone", "controller.isFvdScanDone");
    content = content.replaceAll(
        "controller.scannedBarcode", "controller.fvdScannedBarcode");
    content = content.replaceAll(
        "controller.isCameraActive", "controller.isFvdCameraActive");
    content = content.replaceAll(
        "controller.scanController", "controller.fvdScanController");
    content = content.replaceAll(
        "controller.toggleCamera", "controller.toggleFvdCamera");
    content = content.replaceAll(
        "controller.completeScan", "controller.completeFvdScan");
    content =
        content.replaceAll("controller.skipScan", "controller.skipFvdScan");
    content = content.replaceAll(
        "controller.otpController", "controller.fvdOtpController");
    content = content.replaceAll("controller.otpText", "controller.fvdOtpText");
    content = content.replaceAll(
        "controller.isOtpVerified", "controller.isFvdOtpVerified");
    content = content.replaceAll(
        "controller.isOtpStepValid", "controller.isFvdOtpStepValid");
    content = content.replaceAll(
        "controller.selectedRecipient", "controller.fvdSelectedRecipient");
    content = content.replaceAll(
        "controller.isOptionsStepValid", "controller.isFvdOptionsStepValid");
    content = content.replaceAll("controller.recipientNameController",
        "controller.fvdRecipientNameController");
    content = content.replaceAll("controller.recipientPhoneController",
        "controller.fvdRecipientPhoneController");
    content = content.replaceAll("controller.otherAddressController",
        "controller.fvdOtherAddressController");
    content =
        content.replaceAll("controller.nameText", "controller.fvdNameText");
    content =
        content.replaceAll("controller.phoneText", "controller.fvdPhoneText");
    content = content.replaceAll("controller.isRecipientDetailsStepValid",
        "controller.isFvdRecipientDetailsStepValid");
    content = content.replaceAll("controller.selectedPaymentMethod",
        "controller.fvdSelectedPaymentMethod");
    content = content.replaceAll(
        "controller.paymentDetails", "controller.fvdPaymentDetails");
    content = content.replaceAll(
        "controller.isPaymentVerified", "controller.isFvdPaymentVerified");
    content = content.replaceAll(
        "controller.isPaymentStepValid", "controller.isFvdPaymentStepValid");
    content = content.replaceAll("controller.images", "controller.fvdImages");
    content = content.replaceAll(
        "controller.isImageStepValid", "controller.isFvdImageStepValid");
    content =
        content.replaceAll("controller.nextStep", "controller.nextFvdStep");
    content = content.replaceAll(
        "controller.previousStep", "controller.previousFvdStep");
    content = content.replaceAll("controller.pickImage",
        "controller.pickImage"); // Keep same, actually QuickFlowController has pickImage(index, isPickup)

    newFile.writeAsStringSync(content);
    print('Copied and modified $newFileName');
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/whatsapp_scan_service.dart';
import '../models/whatsapp_contact.dart';

part 'whatsapp_provider.g.dart';

@riverpod
Future<List<WhatsAppContact>> whatsappContacts(WhatsappContactsRef ref) async {
  // Only scan if we have some form of storage permission
  final status = await Permission.manageExternalStorage.status;
  final legacyStatus = await Permission.storage.status;
  final photosStatus = await Permission.photos.status;

  if (!status.isGranted && !legacyStatus.isGranted && !photosStatus.isGranted) {
    return [];
  }

  final scanService = WhatsAppScanService();
  return await scanService.scanContacts();
}

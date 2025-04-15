import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:khatabook/data/models/contact.dart' as app_contact;
import 'package:permission_handler/permission_handler.dart';

class ContactPickerService {
  // Request contacts permission
  static Future<bool> requestPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  // Open contact picker and return selected contact
  static Future<app_contact.Contact?> pickContact() async {

    if (!await requestPermission()) {
      return null;
    }

    try {
      // Open the contact picker
      final contact = await FlutterContacts.openExternalPick();


      if (contact == null) {
        return null;
      }

      // Get full contact with all details
      final fullContact = await FlutterContacts.getContact(contact.id);

      if (fullContact == null) {
        return null;
      }

      // Convert to our app's contact model
      final phoneNumber = fullContact.phones.isNotEmpty
          ? fullContact.phones.first.number
          : '';

      return app_contact.Contact(
        name: '${fullContact.name.first} ${fullContact.name.last}'.trim(),
        phone: phoneNumber,
        type: 'customer', // Default type is customer
        notes: '',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error picking contact: $e');
      return null;
    }
  }
}
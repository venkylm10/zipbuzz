import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/services/permission_handler.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

final contactsServicesProvider = Provider<ContactsServices>((ref) {
  return ContactsServices(ref: ref);
});

class ContactsServices {
  final Ref ref;
  const ContactsServices({required this.ref});

  Future<List<Contact>> getContacts() async {
    try {
      var contacts = <Contact>[];
      if (await ref.read(appPermissionsProvider).getContactsPermission()) {
        contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withThumbnail: true,
          withPhoto: true,
        );
        ref.read(newEventProvider.notifier).updateAllContacts(contacts);
        ref.read(newEventProvider.notifier).resetContactSearch();
      } else {
        showSnackBar(message: "We need your permission to access your contacts");
        if (await ref.read(appPermissionsProvider).getContactsPermission()) {
          contacts = await FlutterContacts.getContacts();
        }
      }
      return contacts;
    } catch (e) {
      debugPrint("Error getting contacts: $e");
      rethrow;
    }
  }

  Future<void> updateAllContacts() async {
    final contacts = await getContacts();
    ref.read(newEventProvider.notifier).updateAllContacts(contacts);
  }
}

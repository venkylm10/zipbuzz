import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/services/permission_handler.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

final contactsServicesProvider = Provider<Contacts>((ref) {
  return Contacts(ref: ref);
});

class Contacts {
  final Ref ref;
  const Contacts({required this.ref});

  Future<List<Contact>> getContacts() async {
    if (kIsWeb) return <Contact>[];
    try {
      var contacts = <Contact>[];
      if (await ref.read(appPermissionsProvider).getContactsPermission()) {
        contacts = await ContactsService.getContacts().then(
          (value) => value.where((element) {
            var check = element.phones != null && element.phones!.isNotEmpty;
            return check;
          }).toList(),
        );
        ref.read(newEventProvider.notifier).updateAllContacts(contacts);
        ref.read(newEventProvider.notifier).resetContactSearch();
        ref.read(editEventControllerProvider.notifier).updateAllContacts(contacts);
        ref.read(editEventControllerProvider.notifier).resetContactSearch();
      } else {
        showSnackBar(message: "We need contact permission to invite people");
        if (await ref.read(appPermissionsProvider).getContactsPermission()) {
          contacts = await ContactsService.getContacts().then(
            (value) => value.where((element) {
              var check = element.phones != null && element.phones!.isNotEmpty;
              return check;
            }).toList(),
          );
        }
      }
      return contacts;
    } catch (e) {
      debugPrint("Error getting contacts: $e");
      rethrow;
    }
  }

  Future<void> updateAllContacts() async {
    if (kIsWeb) return;
    final contacts = await getContacts()
        .then((value) => value.where((element) => element.phones != null).toList());
    ref.read(newEventProvider.notifier).updateAllContacts(contacts);
    ref.read(editEventControllerProvider.notifier).updateAllContacts(contacts);
  }

  List<Contact> getMatchingContacts(List<String> numbers) {
    final foundNumbers = <String>[];
    var userNumber =
        ref.read(userProvider).mobileNumber.replaceAll(RegExp(r'[\s()-]+'), "").replaceAll(" ", "");
    if (userNumber.length > 10) {
      userNumber = userNumber.substring(userNumber.length - 10);
    }
    final flattedNumbers = numbers.map((e) {
      var phone = e.replaceAll(RegExp(r'[\s()-]+'), "").replaceAll(" ", "");
      if (phone.length > 10) {
        phone = phone.substring(phone.length - 10);
      }
      return phone;
    }).toList();
    final contacts = ref.read(editEventControllerProvider.notifier).allContacts;
    final matchingContacts = contacts.where((element) {
      final contactNumbers = element.phones!.map((e) {
        var phone = (e.value ?? "").replaceAll(RegExp(r'[\s()-]+'), "").replaceAll(" ", "");
        if (phone.length > 10) {
          phone = phone.substring(phone.length - 10);
        }
        return phone;
      }).toList();
      if (userNumber == contactNumbers.first) {
        return false;
      }
      final contains = flattedNumbers.contains(contactNumbers.first);
      if (contains) {
        if (foundNumbers.contains(contactNumbers.first)) {
          return false;
        } else {
          foundNumbers.add(contactNumbers.first);
          return true;
        }
      }
      return false;
    }).toList();
    return matchingContacts;
  }
}

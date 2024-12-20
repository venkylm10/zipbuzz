import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/services/permission_handler.dart';
import 'package:zipbuzz/utils/constants/defaults.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

class ContactModel {
  final String displayName;
  final List<String> phones;
  final String imageUrl;
  final List<String>? email;

  ContactModel({
    required this.displayName,
    required this.phones,
    this.imageUrl = Defaults.contactAvatarUrl,
    this.email,
  });
}

final contactsServicesProvider = Provider<Contacts>((ref) {
  return Contacts(ref: ref);
});

class Contacts {
  final Ref ref;
  Contacts({required this.ref});

  List<ContactModel> _fetchedContacts = [];

  int _permissonCount = 0;

  Future<List<ContactModel>> getContacts() async {
    _permissonCount++;
    if (_permissonCount >= 3) {
      _permissonCount = 0;
      return <ContactModel>[];
    }
    if (kIsWeb) return <ContactModel>[];
    try {
      var contactModels = <ContactModel>[];
      if (await ref.read(appPermissionsProvider).getContactsPermission()) {
        contactModels = (await ContactsService.getContacts().then(
          (value) => value.where((element) {
            var check = element.phones != null && element.phones!.isNotEmpty;
            return check;
          }).toList(),
        ))
            .map((e) {
          Set<String> phones = {};
          for (var num in e.phones!) {
            final phone = flattenNumber(num.value!, ref, null);
            phones.add(phone);
          }
          return ContactModel(
            displayName: e.displayName ?? "zipbuzz-null",
            phones: phones.toList(),
            email: e.emails != null
                ? e.emails!.isNotEmpty
                    ? e.emails!.map((e) => e.value!).toList()
                    : null
                : null,
          );
        }).toList();
        ref.read(newEventProvider.notifier).updateAllContacts(contactModels);
        ref.read(newEventProvider.notifier).resetContactSearch();
        ref.read(editEventControllerProvider.notifier).updateAllContacts(contactModels);
        ref.read(editEventControllerProvider.notifier).resetContactSearch();
        ref.read(groupControllerProvider.notifier).updateAllContacts(contactModels);
        ref.read(groupControllerProvider.notifier).resetContactSearchResult();
      } else {
        showSnackBar(message: "We need contact permission to invite people");
        return await getContacts();
      }
      _fetchedContacts = contactModels;
      _permissonCount = 0;
      return contactModels;
    } catch (e) {
      debugPrint("Error getting contacts: $e");
      _permissonCount = 0;
      rethrow;
    }
  }

  Future<void> updateAllContacts() async {
    if (kIsWeb) return;
    final contacts = await getContacts();
    ref.read(newEventProvider.notifier).updateAllContacts(contacts);
    ref.read(editEventControllerProvider.notifier).updateAllContacts(contacts);
    ref.read(groupControllerProvider.notifier).updateAllContacts(contacts);
  }

  List<ContactModel> getMatchingContacts(List<String> numbers) {
    final foundNumbers = <String>[];
    var userNumber = flattenNumber(ref.read(userProvider).mobileNumber, ref, null);
    final flattedNumbers = numbers.map((e) => flattenNumber(e, ref, null)).toList();
    final contacts = _fetchedContacts;
    final matchingContacts = contacts.where((element) {
      final contactNumbers = element.phones;
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

  static String flattenNumber(String number, Ref? ref, WidgetRef? widgetRef) {
    assert(ref != null || widgetRef != null);
    late final String userMobileNumber;
    if (ref != null) {
      userMobileNumber = ref.read(userProvider).mobileNumber;
    } else {
      userMobileNumber = widgetRef!.read(userProvider).mobileNumber;
    }
    final userCode =
        userMobileNumber.substring(0, userMobileNumber.length - 10).replaceAll("+", "");

    final cleanedNumber = number.replaceAll(RegExp(r'[\s()\-+]'), "");
    if (cleanedNumber.length > 10) {
      final countryCode = cleanedNumber.substring(0, cleanedNumber.length - 10).replaceAll("+", "");
      return "+$countryCode${cleanedNumber.substring(cleanedNumber.length - 10)}";
    } else if (cleanedNumber.length == 10) {
      return "+$userCode$cleanedNumber";
    }
    return cleanedNumber;
  }
}

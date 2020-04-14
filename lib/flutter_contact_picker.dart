import 'dart:async';

import 'package:flutter/services.dart';

class FlutterContactPicker {
  static const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/contact');

  /// 获取通讯录列表
  Future<List<Contact>> selectContacts() async {
    final List result = await _channel.invokeMethod('selectContactList');
    if (result == null) {
      return null;
    }
    List<Contact> contacts = new List();
    result.forEach((f) {
      contacts.add(new Contact.fromMap(f));
    });
    return contacts;
  }

  /// 打开原生通讯录
  Future<Contact> selectContactWithNative() async {
    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('goToContact');
    if (result == null) {
      return null;
    }
    return new Contact.fromMap(result);
  }
}

/// Represents a contact selected by the user.
class Contact {
  Contact({this.contactName, this.phoneNumber, this.firstLetter});

  factory Contact.fromMap(Map<dynamic, dynamic> map) => new Contact(
        contactName: map['contactName'],
        phoneNumber: map['phoneNumber'],
        firstLetter: map['firstLetter'],
      );

  /// The full name of the contact, e.g. "Dr. Daniel Higgens Jr.".
  final String contactName;

  /// The phone number of the contact.
  final String phoneNumber;

  /// The firstLetter of the fullName.
  final String firstLetter;

  @override
  String toString() => '$contactName: $phoneNumber';
}

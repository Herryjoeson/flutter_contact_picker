import 'package:contact/flutter_contact_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HostPage extends StatefulWidget {
  @override
  _HostPageState createState() => _HostPageState();
}

class _HostPageState extends State<HostPage>
    with AutomaticKeepAliveClientMixin {
  Contact _contact = new Contact(contactName: "", phoneNumber: "");
  final FlutterContactPicker _contactPicker = new FlutterContactPicker();

  _openAddressBook() async {
    // 申请权限
    final PermissionStatus status = await Permission.contacts.status;
    if ([
      PermissionStatus.undetermined,
      PermissionStatus.denied,
    ].contains(status)) {
      Map<Permission, PermissionStatus> status = await [
        Permission.contacts,
      ].request();

      if (status[Permission.contacts] == PermissionStatus.granted) {
        _getContactData();
      }
    } else if (status == PermissionStatus.granted) {
      _getContactData();
    }
  }

  _getContactData() async {
    final Contact contact = await _contactPicker.selectContactWithNative();
    print(contact);
    setState(() {
      _contact = contact;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("首页"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(13, 20, 13, 10),
            child: Row(
              children: <Widget>[Text("姓名："), Text(_contact.contactName)],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(13, 0, 13, 20),
            child: Row(
              children: <Widget>[Text("手机号："), Text(_contact.phoneNumber)],
            ),
          ),
          FlatButton(
            child: Text("打开通讯录"),
            onPressed: _openAddressBook,
          )
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

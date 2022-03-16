import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_from_json/approval_request_list.dart';
import 'package:form_from_json/new_approval_page2.dart';
import 'package:function_tree/function_tree.dart';

import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'package:signature/signature.dart';

class NewApprovalStep1 extends StatefulWidget {
  const NewApprovalStep1({Key? key}) : super(key: key);

  @override
  State<NewApprovalStep1> createState() => _NewApprovalStep1State();
}

class _NewApprovalStep1State extends State<NewApprovalStep1> {
  final _remarkController = TextEditingController();
  final _notificationController = TextEditingController();
  final List<String> selectedList = [];
  List<NotificatioNameListDetails?> _selectedNotifyUsers = [];

  NotificatioNameList? _notificatioNameList;
  List<String> notifyListId = [];

  List<String> listOFSelectedItem = [];
  String selectedText = "";

  @override
  void initState() {
    super.initState();
    _remarkController.text = "";
    _notificationController.text = "";
    loadNotificationList().then((value) => {
          setState(() {
            _notificatioNameList = value;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(onPressed: () => refreshForm()),
      appBar: AppBar(
        title: Text("1 - Key Information"),
      ),
      body: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(8.0)),
              Container(
                alignment: AlignmentDirectional.topStart,
                child: const Text(
                  "REMARKS",
                  textAlign: TextAlign.left,
                ),
              ),
              const Padding(padding: EdgeInsets.all(5.0)),
              FormBuilderTextField(
                name: "remarks",
                controller: _remarkController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const Padding(padding: EdgeInsets.all(5.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: AlignmentDirectional.topStart,
                    child: const Text(
                      "SEND NOTIFICATION TO",
                      textAlign: TextAlign.left,
                    ),
                  ),
                  TextButton(
                    child: Text("Clear"),
                    onPressed: () {
                      setState(() {
                        _selectedNotifyUsers.clear();
                      });
                    },
                  ),
                ],
              ),
              _notificatioNameList != null
                  ? MultiSelectBottomSheetField<NotificatioNameListDetails?>(
                      initialChildSize: 0.7,
                      maxChildSize: 0.95,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                      ),
                      items: _notificatioNameList!.notificationList
                          .map((value) => MultiSelectItem<NotificatioNameListDetails?>(value, value.firstName + " " + value.lastName))
                          .toList(),
                      onConfirm: (values) {
                        setState(() {
                          _selectedNotifyUsers = values;
                        });
                      },
                      chipDisplay: MultiSelectChipDisplay(
                        onTap: (item) {
                          setState(() {
                            _selectedNotifyUsers.remove(item);
                          });
                        },
                      ),
                    )
                  : Container(),
              const Padding(padding: EdgeInsets.all(8.0)),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  child: const Text("Next"),
                  onPressed: () {
                    for (var item in _selectedNotifyUsers) {
                      notifyListId.add(item!.id);
                    }

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewApprovalStep2(
                                  remarks: _remarkController.text,
                                  notifyUser: notifyListId,
                                )));
                  },
                ),
              ),
            ],
          )),
    );
  }

  Future<NotificatioNameList> loadNotificationList() async {
    try {
      String response = await rootBundle.loadString('assets/DropDownNotificationName.json');

      NotificatioNameList result = NotificatioNameList.fromJson(json.decode(response));

      return result;
    } catch (e) {
      throw e;
    }
  }
}

class _ViewItem extends StatelessWidget {
  NotificatioNameListDetails item;
  bool itemSelected;
  final Function(String) selected;

  _ViewItem({required this.item, required this.itemSelected, required this.selected});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(left: size.width * .032, right: size.width * .098),
      child: Row(
        children: [
          SizedBox(
            height: 24.0,
            width: 24.0,
            child: Checkbox(
              value: itemSelected,
              onChanged: (val) {
                selected(item.id);
              },
            ),
          ),
          SizedBox(
            width: size.width * .025,
          ),
          Text(
            item.firstName + " " + item.lastName,
          ),
        ],
      ),
    );
  }
}

class NotificatioNameList {
  NotificatioNameList({
    required this.notificationList,
  });

  List<dynamic> notificationList;

  factory NotificatioNameList.fromJson(Map<String, dynamic> json) => NotificatioNameList(
        notificationList:
            json["notificationList"] == null ? [] : json["notificationList"].map((n) => NotificatioNameListDetails.fromJson(n)).toList(),
      );
}

class NotificatioNameListDetails {
  NotificatioNameListDetails({
    required this.firstName,
    required this.lastName,
    required this.id,
  });

  String firstName;
  String lastName;
  String id;

  factory NotificatioNameListDetails.fromJson(Map<String, dynamic> json) => NotificatioNameListDetails(
        firstName: json["firstName"] == null ? null : json["firstName"],
        lastName: json["lastName"] == null ? null : json["lastName"],
        id: json["id"] == null ? null : json["id"],
      );
}

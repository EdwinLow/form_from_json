import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_from_json/new_approval_page1.dart';
import 'package:function_tree/function_tree.dart';
import 'package:signature/signature.dart';

import 'approval_request_detail_page.dart';

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({Key? key}) : super(key: key);

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  ApprovalList? _approvalList;

  @override
  void initState() {
    super.initState();
    loadApprovalList().then((value) {
      setState(() {
        _approvalList = value;
        print(value.approvalList[0].currentStatus.statusName);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(onPressed: () => refreshForm()),
      appBar: AppBar(
        title: Text("Approval"),
      ),
      body: Column(
        children: [
          _approvalList == null
              ? Container()
              : SingleChildScrollView(
                  physics: ScrollPhysics(),
                  child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _approvalList!.approvalList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RequestDetail(requestDetail: _approvalList!.approvalList[index])),
                            )
                          },
                          child: Card(
                            margin: EdgeInsets.all(10),
                            child: Container(
                              margin: EdgeInsets.all(5),
                              height: 100,
                              child: Column(
                                children: [
                                  Divider(
                                    thickness: 2,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 100,
                                        child: Text(_approvalList!.approvalList[index].currentStatus.statusName),
                                      ),
                                      Container(
                                        width: 200,
                                        child: index == 0 ? Text("Mohammad Assad") : Text(""),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
          Center(
            child: ElevatedButton(
              child: Text("New Approval"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewApprovalStep1()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<ApprovalList> loadApprovalList() async {
    try {
      String response = await rootBundle.loadString('assets/approvallist.json');

      ApprovalList result = ApprovalList.fromJson(json.decode(response));

      return result;
    } catch (e) {
      throw e;
    }
  }
}

class ApprovalList {
  ApprovalList({
    required this.approvalList,
  });

  List<dynamic> approvalList;

  factory ApprovalList.fromJson(Map<String, dynamic> json) => ApprovalList(
        approvalList: json["approvalList"] == null ? [] : json["approvalList"].map((n) => ApprovalListDetails.fromJson(n)).toList(),
      );
}

class ApprovalListDetails {
  ApprovalListDetails({
    required this.id,
    required this.entityId,
    required this.remarks,
    required this.currentStepId,
    required this.submitUser,
    required this.currentStatus,
    required this.createdOn,
    required this.currentStep,
  });

  int id;
  String entityId;
  String remarks;
  int currentStepId;
  dynamic submitUser;
  dynamic currentStatus;
  String createdOn;
  dynamic currentStep;

  factory ApprovalListDetails.fromJson(dynamic json) => ApprovalListDetails(
        id: json["id"] == null ? null : json["id"],
        entityId: json["entityId"] == null ? "" : json["entityId"],
        remarks: json["remarks"] == null ? "" : json["remarks"],
        currentStepId: json["currentStepId"] == null ? null : json["currentStepId"],
        createdOn: json["createdOn"] == null ? null : json["createdOn"],
        submitUser: json["submitUser"] == null ? null : SubmitUser.fromJson(json["submitUser"]),
        currentStatus: json["currentStatus"] == null ? null : CurrentStatus.fromJson(json["currentStatus"]),
        currentStep: json["currentStep"] == null ? null : CurrentStep.fromJson(json["currentStep"]),
      );
}

class SubmitUser {
  SubmitUser({
    required this.firstName,
    required this.lastName,
  });

  String firstName;
  String lastName;

  factory SubmitUser.fromJson(dynamic json) => SubmitUser(
        firstName: json["firstName"] == null ? "" : json["firstName"],
        lastName: json["lastName"] == null ? "" : json["lastName"],
      );
}

class CurrentStatus {
  CurrentStatus({
    required this.statusName,
    required this.roleCodes,
  });

  String statusName;
  List<String> roleCodes;

  factory CurrentStatus.fromJson(dynamic json) => CurrentStatus(
        statusName: json["statusName"] == null ? "" : json["statusName"],
        roleCodes: json["roleCodes"] == null ? [] : json["roleCodes"].map((n) => n).toList(),
      );
}

class CurrentStep {
  CurrentStep({
    required this.stepName,
  });

  String stepName;

  factory CurrentStep.fromJson(dynamic json) => CurrentStep(
        stepName: json["stepName"] == null ? "" : json["stepName"],
      );
}

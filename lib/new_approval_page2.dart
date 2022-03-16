import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:function_tree/function_tree.dart';
import 'package:signature/signature.dart';

class NewApprovalStep2 extends StatefulWidget {
  const NewApprovalStep2({Key? key, required this.remarks, required this.notifyUser}) : super(key: key);
  final String remarks;
  final List<String> notifyUser;

  @override
  State<NewApprovalStep2> createState() => _NewApprovalStep2State();
}

class _NewApprovalStep2State extends State<NewApprovalStep2> {
  ApprovalFlow? _approvalFlow;

  final Map<String, dynamic> dataOutput = Map<String, dynamic>();

  @override
  void initState() {
    super.initState();
    loadApprovalFlow().then((value) => {
          setState(() {
            _approvalFlow = value;
          }),
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(onPressed: () => refreshForm()),
      appBar: AppBar(
        title: Text("2 - Approval Document"),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.all(8.0)),
            Container(
              alignment: AlignmentDirectional.topStart,
              child: const Text(
                "Approval Documents",
                textAlign: TextAlign.left,
              ),
            ),
            const Padding(padding: EdgeInsets.all(5.0)),
            Container(
              alignment: AlignmentDirectional.topStart,
              child: const Text(
                "* STD",
                textAlign: TextAlign.left,
              ),
            ),
            const Padding(padding: EdgeInsets.all(5.0)),
            Container(
              alignment: AlignmentDirectional.topStart,
              child: Row(
                children: [
                  Icon(Icons.file_copy),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Print From File",
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.all(5.0)),
            Container(
              alignment: AlignmentDirectional.topStart,
              child: const Text(
                "SUPPORT",
                textAlign: TextAlign.left,
              ),
            ),
            const Padding(padding: EdgeInsets.all(5.0)),
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TextButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey.shade400)),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [Icon(Icons.download), Text('UPLOAD')]),
                onPressed: () {},
              ),
            ]),
            const Padding(padding: EdgeInsets.all(5.0)),
            Container(
              alignment: AlignmentDirectional.topStart,
              child: const Text(
                "Approval Flow",
                textAlign: TextAlign.left,
              ),
            ),
            const Padding(padding: EdgeInsets.all(5.0)),
            _approvalFlow == null
                ? Container()
                : SingleChildScrollView(
                    physics: ScrollPhysics(),
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _approvalFlow!.steps.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Divider(
                                thickness: 2,
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 100,
                                    child: Text(_approvalFlow!.steps[index].roleCodes[0]),
                                  ),
                                  Container(
                                    width: 200,
                                    child: index == 0 ? Text("Mohammad Assad") : Text(""),
                                  )
                                ],
                              ),
                            ],
                          );
                        }),
                  ),
            const Padding(padding: EdgeInsets.all(8.0)),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                child: Text("SAVE"),
                onPressed: () {
                  dataOutput['remarks'] = widget.remarks;
                  dataOutput['nofifyUsers'] = widget.notifyUser;
                  dataOutput['approvalDocuments'] = [];

                  print(dataOutput);
                  print(json.encode(dataOutput));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<ApprovalFlow> loadApprovalFlow() async {
    try {
      String response = await rootBundle.loadString('assets/ApprovalFlowStd.json');

      ApprovalFlow result = ApprovalFlow.fromJson(json.decode(response));

      return result;
    } catch (e) {
      throw e;
    }
  }
}

class ApprovalFlow {
  ApprovalFlow({
    required this.id,
    required this.registerId,
    required this.flowName,
    required this.createdOn,
    required this.updatedOn,
    required this.steps,
  });

  int id;
  int registerId;
  String flowName;
  String createdOn;
  String updatedOn;
  List<dynamic> steps;

  factory ApprovalFlow.fromJson(Map<String, dynamic> json) => ApprovalFlow(
        id: json["id"] == null ? null : json["id"],
        registerId: json["registerId"] == null ? null : json["registerId"],
        flowName: json["flowName"] == null ? null : json["flowName"],
        createdOn: json["createdOn"] == null ? null : json["createdOn"],
        updatedOn: json["updatedOn"] == null ? null : json["updatedOn"],
        steps: json["steps"] == null ? [] : json["steps"].map((n) => ApprovalFlowSteps.fromJson(n)).toList(),
      );
}

class ApprovalFlowSteps {
  ApprovalFlowSteps({
    required this.id,
    required this.flowId,
    required this.stepName,
    required this.roleCodes,
  });

  int id;
  int flowId;
  String stepName;
  List<dynamic> roleCodes;

  factory ApprovalFlowSteps.fromJson(dynamic json) => ApprovalFlowSteps(
        id: json["id"] == null ? null : json["id"],
        flowId: json["flowId"] == null ? null : json["flowId"],
        stepName: json["stepName"] == null ? false : json["stepName"],
        roleCodes: json["roleCodes"] == null ? [] : json["roleCodes"].map((n) => n).toList(),
      );
}

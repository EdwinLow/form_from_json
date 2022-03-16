import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_from_json/approval_request_list.dart';
import 'package:form_from_json/new_approval_page1.dart';
import 'package:function_tree/function_tree.dart';
import 'package:signature/signature.dart';

import 'new_approval_page2.dart';

class RequestDetail extends StatefulWidget {
  const RequestDetail({Key? key, required this.requestDetail}) : super(key: key);
  final ApprovalListDetails requestDetail;

  @override
  State<RequestDetail> createState() => _RequestDetailState();
}

class _RequestDetailState extends State<RequestDetail> {
  ApprovalFlow? _approvalFlow;
  var currentStatusIndex = 0;
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
        title: Text("Approval"),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            widget.requestDetail == null
                ? Container()
                : Card(
                    margin: EdgeInsets.all(10),
                    child: Container(
                      margin: EdgeInsets.all(5),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 150,
                                child: Text("Status"),
                              ),
                              Container(
                                width: 200,
                                child: Text(widget.requestDetail.currentStatus.statusName),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 150,
                                child: Text("Submitted User"),
                              ),
                              Container(
                                width: 200,
                                child: Text(widget.requestDetail.submitUser.firstName + " " + widget.requestDetail.submitUser.lastName),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 150,
                                child: Text("Requested Date"),
                              ),
                              Container(
                                width: 200,
                                child: Text(widget.requestDetail.createdOn),
                              )
                            ],
                          ),
                          const Padding(padding: EdgeInsets.all(10.0)),
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
                                        if (_approvalFlow!.steps[index].stepName == widget.requestDetail.currentStep.stepName) {
                                          currentStatusIndex = index;
                                        }

                                        print(_approvalFlow!.steps[index].stepName);
                                        print(widget.requestDetail.currentStep.stepName);
                                        print(index);
                                        print(currentStatusIndex);
                                        return Column(
                                          children: [
                                            Divider(
                                              thickness: 2,
                                            ),
                                            Row(
                                              children: [
                                                Visibility(
                                                    visible: currentStatusIndex != 0 && index == currentStatusIndex, child: Icon(Icons.arrow_right)),
                                                Container(
                                                  width: 100,
                                                  child: Text(_approvalFlow!.steps[index].roleCodes[0]),
                                                ),
                                                index == 0
                                                    ? Container(
                                                        width: 200,
                                                        child: Text(widget.requestDetail.submitUser.firstName +
                                                            " " +
                                                            widget.requestDetail.submitUser.lastName),
                                                      )
                                                    : index == currentStatusIndex
                                                        ? Container(
                                                            width: 200,
                                                            child: Text("Pending Approval"),
                                                          )
                                                        : Container(),
                                              ],
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                        ],
                      ),
                    ),
                  ),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                child: Text("Approve"),
                onPressed: () {
                  print("Approve!!!!!");
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

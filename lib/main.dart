import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:signature/signature.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Add Form Entry'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DynamicForm? _loadedJsonForm;
  List<TextEditingController> _inputFieldController = [];
  String? _outputApi;
  final Map<String, dynamic> dataOutput = Map<String, dynamic>();

  final SignatureController _controller = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.red,
    exportBackgroundColor: Colors.blue,
    onDrawStart: () => print('onDrawStart called!'),
    onDrawEnd: () => print('onDrawEnd called!'),
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => print('Value changed'));

    loadForm().then((value) {
      setState(() {
        _loadedJsonForm = value;

        //create multiple controller
        for (var item in _loadedJsonForm!.definitions) {
          _inputFieldController.add(TextEditingController());
        }
      });
    });
  }

  @override
  void refreshForm() {
    loadForm().then((value) {
      setState(() {
        _loadedJsonForm = value;
        print(_loadedJsonForm!.definitions[0].type);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(onPressed: () => refreshForm()),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _loadedJsonForm == null
          ? const CircularProgressIndicator()
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _loadedJsonForm!.definitions.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == _loadedJsonForm!.definitions.length) {
                  return TextButton(
                    child: Text("Save"),
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange)),
                    onPressed: () => {
                      for (var item in _inputFieldController)
                        {
                          if (_loadedJsonForm!.definitions[_inputFieldController.indexOf(item)].type != "sectionHeader")
                            {
                              dataOutput[_loadedJsonForm!.definitions[_inputFieldController.indexOf(item)].key] = item.text,
                            }
                        },
                      print(dataOutput),
                      print(json.encode(dataOutput)),
                    },
                  );
                } else if (_loadedJsonForm!.definitions[index].type == "number") {
                  return Column(
                    children: [
                      const Padding(padding: EdgeInsets.all(8.0)),
                      Container(
                        alignment: AlignmentDirectional.topStart,
                        child: Text(
                          _loadedJsonForm!.definitions[index].label,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.all(5.0)),
                      FormBuilderTextField(
                        keyboardType: TextInputType.number,
                        name: _loadedJsonForm!.definitions[index].label,
                        controller: _inputFieldController[index],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  );
                } else if (_loadedJsonForm!.definitions[index].type == "textfield") {
                  return Column(
                    children: [
                      const Padding(padding: EdgeInsets.all(8.0)),
                      Container(
                        alignment: AlignmentDirectional.topStart,
                        child: Text(
                          _loadedJsonForm!.definitions[index].label,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.all(5.0)),
                      FormBuilderTextField(
                        name: _loadedJsonForm!.definitions[index].label,
                        controller: _inputFieldController[index],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  );
                } else if (_loadedJsonForm!.definitions[index].type == "sectionHeader") {
                  return Column(
                    children: [
                      const Padding(padding: EdgeInsets.all(8.0)),
                      Container(
                        alignment: AlignmentDirectional.topStart,
                        child: Text(
                          _loadedJsonForm!.definitions[index].label,
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                } else if (_loadedJsonForm!.definitions[index].type == "textarea") {
                  return Column(
                    children: [
                      const Padding(padding: EdgeInsets.all(8.0)),
                      Container(
                        alignment: AlignmentDirectional.topStart,
                        child: Text(
                          _loadedJsonForm!.definitions[index].label,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(5.0)),
                      FormBuilderTextField(
                        name: _loadedJsonForm!.definitions[index].label,
                        controller: _inputFieldController[index],
                        maxLines: 10,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  );
                } else if (_loadedJsonForm!.definitions[index].type == "checkbox") {
                  //Initialize value
                  _inputFieldController[index].text = "false";
                  return Column(
                    children: [
                      FormBuilderCheckbox(
                        name: _loadedJsonForm!.definitions[index].label,
                        title: Text(_loadedJsonForm!.definitions[index].label),
                        onChanged: (dynamic val) => {
                          _inputFieldController[index].text = val.toString(),
                        },
                      )
                    ],
                  );
                } else if (_loadedJsonForm!.definitions[index].type == "fileUpload") {
                  return Column(
                    children: [
                      Padding(padding: EdgeInsets.all(8.0)),
                      Container(
                        alignment: AlignmentDirectional.topStart,
                        child: Text(
                          _loadedJsonForm!.definitions[index].label,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(5.0)),
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
                    ],
                  );
                } else if (_loadedJsonForm!.definitions[index].type == "radio") {
                  return Column(
                    children: [
                      const Padding(padding: EdgeInsets.all(8.0)),
                      Container(
                        alignment: AlignmentDirectional.topStart,
                        child: Text(
                          _loadedJsonForm!.definitions[index].label,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.all(5.0)),
                      FormBuilderRadioGroup(
                        name: _loadedJsonForm!.definitions[index].label,
                        onChanged: (dynamic val) => _inputFieldController[index].text = val,
                        options: [for (var i in _loadedJsonForm!.definitions[index].values) i.label.toString()]
                            .map((lang) => FormBuilderFieldOption(
                                  value: lang,
                                  child: Text(lang),
                                ))
                            .toList(growable: false),
                        controlAffinity: ControlAffinity.leading,
                        orientation: OptionsOrientation.vertical,
                      )
                    ],
                  );
                } else if (_loadedJsonForm!.definitions[index].type == "signature") {
                  return Column(
                    children: [
                      const Padding(padding: EdgeInsets.all(8.0)),
                      Signature(
                        controller: _controller,
                        height: 200,
                        backgroundColor: Colors.grey.shade400,
                      ),
                      Container(
                        decoration: const BoxDecoration(color: Colors.black54),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            //SHOW EXPORTED IMAGE IN NEW ROUTE
                            IconButton(
                              icon: const Icon(Icons.check),
                              color: Colors.blue,
                              onPressed: () async {
                                if (_controller.isNotEmpty) {
                                  final Uint8List? data = await _controller.toPngBytes();
                                  if (data != null) {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (BuildContext context) {
                                          return Scaffold(
                                            appBar: AppBar(),
                                            body: Center(
                                              child: Container(
                                                color: Colors.grey[300],
                                                child: Image.memory(data),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.undo),
                              color: Colors.blue,
                              onPressed: () {
                                setState(() => _controller.undo());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.redo),
                              color: Colors.blue,
                              onPressed: () {
                                setState(() => _controller.redo());
                              },
                            ),
                            //CLEAR CANVAS
                            IconButton(
                              icon: const Icon(Icons.clear),
                              color: Colors.blue,
                              onPressed: () {
                                setState(() => _controller.clear());
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Text(_loadedJsonForm!.definitions[index].footer),
                      ),
                    ],
                  );
                } else {
                  return Container(
                    height: 50,
                    color: Colors.red,
                    child: const Center(child: Text('No such type')),
                  );
                }
              }),
    );
  }

  Future<DynamicForm> loadForm() async {
    try {
      String response = await rootBundle.loadString('assets/form_3.json');

      DynamicForm result = DynamicForm.fromJson(json.decode(response));

      return result;
    } catch (e) {
      throw e;
    }
  }
}

class DynamicForm {
  DynamicForm({
    required this.code,
    required this.name,
    required this.definitions,
  });

  String code;
  String name;
  List<dynamic> definitions;

  factory DynamicForm.fromJson(Map<String, dynamic> json) => DynamicForm(
        code: json["code"] == null ? null : json["code"],
        name: json["name"] == null ? null : json["name"],
        definitions: json["definitions"] == null ? [] : json["definitions"].map((n) => DynamicFormDefinition.fromJson(n)).toList(),
      );
}

class DynamicFormDefinition {
  DynamicFormDefinition({
    required this.id,
    required this.key,
    required this.mask,
    required this.type,
    required this.input,
    required this.label,
    required this.values,
    required this.footer,
  });

  String id;
  String key;
  bool mask;
  String type;
  bool input;
  String label;
  List<dynamic> values;
  String footer;

  factory DynamicFormDefinition.fromJson(dynamic json) => DynamicFormDefinition(
        id: json["id"] == null ? null : json["id"],
        key: json["key"] == null ? null : json["key"],
        mask: json["mask"] == null ? false : json["mask"],
        type: json["type"] == null ? null : json["type"],
        input: json["input"] == null ? false : json["input"],
        label: json["label"] == null ? null : json["label"],
        values: json["values"] == null ? [] : json["values"].map((n) => DynamicFormDefinitionValues.fromJson(n)).toList(),
        footer: json["footer"] == null ? "" : json["footer"],
      );
}

class DynamicFormDefinitionValues {
  DynamicFormDefinitionValues({
    required this.label,
    required this.value,
  });

  String label;
  String value;

  factory DynamicFormDefinitionValues.fromJson(dynamic json) => DynamicFormDefinitionValues(
        label: json["label"] == null ? null : json["label"],
        value: json["value"] == null ? null : json["value"],
      );
}

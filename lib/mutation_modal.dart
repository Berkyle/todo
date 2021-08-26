import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MutationModal<T> extends StatefulWidget {
  final String? title;
  final void Function(String title) onSave;

  MutationModal({this.title, required this.onSave}) : super();

  @override
  State<StatefulWidget> createState() => _MutationModalState();
}

class _MutationModalState extends State<MutationModal> {
  final _titleController = TextEditingController();
  String? get title => super.widget.title;
  void Function(String title) get onSave => super.widget.onSave;

  @override
  void initState() {
    if (title != null) {
      _titleController.text = title!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Cubit context passed via modal
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Column(children: [
        TextField(
          controller: _titleController,
          autofocus: true,
          maxLines: 3,
          minLines: 1,
          onTap: () {
            _titleController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _titleController.value.text.length,
            );
          },
          decoration: InputDecoration(hintText: 'Enter todo title'),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final todoTitle = _titleController.text;
                  onSave(todoTitle);
                  _titleController.text = '';
                  Navigator.of(context).pop();
                },
                child: Text('Save Todo'),
              ),
            ],
          ),
        )
      ]),
    );
  }
}

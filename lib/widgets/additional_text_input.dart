import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:code_and_tree/providers/file_provider.dart';

class AdditionalTextInput extends StatefulWidget {
  const AdditionalTextInput({super.key});

  @override
  State<AdditionalTextInput> createState() => _AdditionalTextInputState();
}

class _AdditionalTextInputState extends State<AdditionalTextInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<FileProvider>(context);

    // fileProvider의 additionalText가 비어있으면 controller도 초기화
    if (fileProvider.additionalText.isEmpty && _controller.text.isNotEmpty) {
      _controller.clear();
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: 'Additional Text',
          hintText: 'Enter text to be added at the end of the generated file',
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withOpacity(0.3),
          alignLabelWithHint: true,
          contentPadding: const EdgeInsets.all(12),
        ),
        expands: true,
        minLines: null,
        maxLines: null,
        textAlignVertical: TextAlignVertical.top,
        onChanged: (value) {
          fileProvider.setAdditionalText(value);
        },
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

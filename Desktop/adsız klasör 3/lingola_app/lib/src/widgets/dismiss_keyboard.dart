import 'package:flutter/material.dart';

/// Boş alana dokunulduğunda klavyeyi kapatır.
/// TextField/TextFormField içeren sayfalarda body'yi bu widget ile sarın.
class DismissKeyboard extends StatelessWidget {
  const DismissKeyboard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

import 'package:flutter/cupertino.dart';

class AnimatedMessage {
  Future<void> animatedWelcome({
    required BuildContext context,
    required void Function(String) onUpdate,
    required String textMessage,
    Duration speed = const Duration(milliseconds: 250),
  }) async {
    String current = '';
    for (var char in textMessage.split('')) {
      current += char;
      onUpdate(current);
      await Future.delayed(speed);
    }
  }
}

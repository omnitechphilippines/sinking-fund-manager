import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: <InlineSpan>[
                  TextSpan(text: '© 2025 ', style: Theme.of(context).textTheme.titleSmall),
                  TextSpan(text: 'Omni Tech Philippines', style: const TextStyle(color: Colors.blue), recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse('https://omnitechphilippines.dev'))),
                  TextSpan(text: '. All rights reserved.', style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

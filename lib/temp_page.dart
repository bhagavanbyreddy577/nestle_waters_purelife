import 'package:flutter/material.dart';
import 'package:nestle_waters_purelife/utils/styles/text_style.dart';

class TempScreen extends StatelessWidget {
  const TempScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Styles Showcase')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading Styles
            Text('Heading Large', style: NTextStyles.headingLarge),
            Text('Heading Medium', style: NTextStyles.headingMedium),
            Text('Heading Small', style: NTextStyles.headingSmall),

            const SizedBox(height: 20),

            // Body Text Styles
            Text('Body Large', style: NTextStyles.bodyLarge),
            Text('Body Medium', style: NTextStyles.bodyMedium),
            Text('Body Small', style: NTextStyles.bodySmall),

            const SizedBox(height: 20),

            // Button Text Styles
            ElevatedButton(
              onPressed: () {},
              child: Text('Large Button', style: NTextStyles.buttonLarge),
            ),
            TextButton(
              onPressed: () {},
              child: Text('Medium Button', style: NTextStyles.buttonMedium),
            ),
            OutlinedButton(
              onPressed: () {},
              child: Text('Small Button', style: NTextStyles.buttonSmall),
            ),

            const SizedBox(height: 20),

            // Caption and Special Texts
            Text('Caption Text', style: NTextStyles.captionText),
            Text('Subtitle Text', style: NTextStyles.subtitleText),
            Text('Link Text', style: NTextStyles.linkText),
            Text('Error Text', style: NTextStyles.errorText),

            const SizedBox(height: 20),

            // Custom Text Style Example
            Text(
              'Custom Text Style',
              style: NTextStyles.custom(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

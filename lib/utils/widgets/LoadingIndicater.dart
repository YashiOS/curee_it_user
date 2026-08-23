import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class BubbleLoadingOverlay extends StatelessWidget {
  const BubbleLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent dark background
        Positioned.fill(
          child: Container(
            color: const Color.fromARGB(19, 49, 49, 49).withValues(alpha: 0.3),
          ),
        ),
        // Centered loading indicator
        const Center(
          child: SizedBox(
            height: 80,
            width: 80,
            child: LoadingIndicator(
              indicatorType: Indicator.ballBeat, // bubble-style
              colors: [Colors.white],
              strokeWidth: 2,
              backgroundColor: Colors.transparent,
              pathBackgroundColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}

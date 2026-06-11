import 'package:flutter/material.dart';
import 'package:travel_hub/constant.dart';

class AiPhotoCard extends StatelessWidget {
  final VoidCallback onPressed;

  const AiPhotoCard({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Color(0xfff7f8ff) was near-white — invisible on dark card backgrounds.
        // Use a reliable brightness check that works without Material 3:
        //   dark  → faint white overlay  (slightly elevated surface look)
        //   light → original faint blue-white tint
        color: theme.brightness == Brightness.dark
            ? Colors.white.withOpacity(0.08)
            : const Color(0xfff7f8ff),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "AI Photo Description",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            "Take a photo and get an AI-powered\n"
            "description with audio narration",
            style: TextStyle(
              fontSize: 13,
              // Colors.black54 is invisible on dark backgrounds.
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 16),

          gradientButton(onTap: onPressed),
        ],
      ),
    );
  }
}



Widget gradientButton({required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
      decoration: BoxDecoration(
        gradient: buttonGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.camera_alt, color: kWhite, size: 18),
          SizedBox(width: 6),
          Text(
            "Take Photo",
            style: TextStyle(
              color: kWhite,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}

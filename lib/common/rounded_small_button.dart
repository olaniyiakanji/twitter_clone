import "package:flutter/material.dart";
import "package:twitter_clone/theme/pallete.dart";

class RoundedSmallButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final Color BackgroundColor;
  final Color TextColor;

  const RoundedSmallButton({
    super.key,
    required this.onTap,
    required this.label,
    this.BackgroundColor = Pallete.whiteColor,
    this.TextColor = Pallete.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: TextColor,
          fontSize: 16,
        ),
      ),
      backgroundColor: BackgroundColor,
      labelPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
    );
  }
}

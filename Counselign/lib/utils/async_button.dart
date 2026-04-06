import 'package:flutter/material.dart';

class AsyncButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget child;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final OutlinedBorder? shape;

  const AsyncButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.child,
    this.width,
    this.padding,
    this.backgroundColor,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
        : child;

    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFF0D6EFD),
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape:
              shape ??
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: buttonChild,
      ),
    );
  }
}

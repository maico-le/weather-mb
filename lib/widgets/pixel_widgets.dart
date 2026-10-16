import 'package:flutter/material.dart';

/// Retro Pixel Card with zero border-radius, hard 2px border, and solid offset shadow
class PixelCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double shadowOffset;
  final Color shadowColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const PixelCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor = const Color(0xFF000000),
    this.borderWidth = 2.0,
    this.shadowOffset = 3.0,
    this.shadowColor = const Color(0xFF000000),
    this.padding = const EdgeInsets.all(12),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? Theme.of(context).cardColor;

    final container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: shadowOffset > 0
            ? [
                BoxShadow(
                  color: shadowColor,
                  offset: Offset(shadowOffset, shadowOffset),
                  blurRadius: 0,
                  spreadRadius: 0,
                )
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}

/// Retro Pixel Button with instant mechanical stepped press
class PixelButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color borderColor;
  final double borderWidth;
  final double shadowOffset;
  final EdgeInsetsGeometry padding;
  final bool isSmall;

  const PixelButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor = const Color(0xFF000000),
    this.borderWidth = 2.0,
    this.shadowOffset = 3.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.isSmall = false,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final effectiveBg = !enabled
        ? Colors.grey.shade400
        : (widget.backgroundColor ?? Theme.of(context).colorScheme.primary);

    final effectivePadding = widget.isSmall
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6)
        : widget.padding;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: Duration.zero, // Instant mechanical stepped feel
        margin: EdgeInsets.only(
          top: _isPressed ? widget.shadowOffset : 0,
          left: _isPressed ? widget.shadowOffset : 0,
          right: _isPressed ? 0 : widget.shadowOffset,
          bottom: _isPressed ? 0 : widget.shadowOffset,
        ),
        padding: effectivePadding,
        decoration: BoxDecoration(
          color: effectiveBg,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: widget.borderColor, width: widget.borderWidth),
          boxShadow: (enabled && !_isPressed && widget.shadowOffset > 0)
              ? [
                  BoxShadow(
                    color: widget.borderColor,
                    offset: Offset(widget.shadowOffset, widget.shadowOffset),
                    blurRadius: 0,
                    spreadRadius: 0,
                  )
                ]
              : null,
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: widget.isSmall ? 11 : 13,
            color: widget.textColor ?? Colors.white,
            letterSpacing: 0.5,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Retro Pixel Badge or Tag
class PixelBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData? icon;

  const PixelBadge({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0xFFFFE082),
    this.textColor = const Color(0xFF1E1E1E),
    this.borderColor = const Color(0xFF000000),
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF000000),
            offset: Offset(1.5, 1.5),
            blurRadius: 0,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

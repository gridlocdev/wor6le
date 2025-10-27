import 'package:flutter/material.dart';
import '../models/tile_state.dart';
import '../models/letter_status.dart';
import '../models/arrow_direction.dart';
import '../utils/constants.dart';

class WordleTile extends StatefulWidget {
  final TileState tileState;
  final bool isCurrentRow;
  final int index;
  final bool animate;

  const WordleTile({
    super.key,
    required this.tileState,
    this.isCurrentRow = false,
    this.index = 0,
    this.animate = false,
  });

  @override
  State<WordleTile> createState() => _WordleTileState();
}

class _WordleTileState extends State<WordleTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.animate && widget.tileState.status != LetterStatus.empty) {
      Future.delayed(Duration(milliseconds: widget.index * 100), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void didUpdateWidget(WordleTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate &&
        widget.tileState.status != LetterStatus.empty &&
        oldWidget.tileState.status == LetterStatus.empty) {
      Future.delayed(Duration(milliseconds: widget.index * 100), () {
        if (mounted) _controller.forward();
      });
    }

    // Pop animation for new letter
    if (!widget.animate &&
        widget.isCurrentRow &&
        widget.tileState.letter.isNotEmpty &&
        oldWidget.tileState.letter.isEmpty) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.tileState.status) {
      case LetterStatus.correct:
        return AppColors.correct;
      case LetterStatus.present:
        return AppColors.present;
      case LetterStatus.absent:
        return AppColors.absent;
      case LetterStatus.empty:
        return Colors.transparent;
    }
  }

  Color _getBorderColor() {
    if (widget.tileState.status != LetterStatus.empty) {
      return Colors.transparent;
    }
    return widget.isCurrentRow && widget.tileState.letter.isNotEmpty
        ? AppColors.filledBorder
        : AppColors.emptyBorder;
  }

  Color _getTextColor() {
    return widget.tileState.status == LetterStatus.empty
        ? AppColors.textDark
        : AppColors.textLight;
  }

  Widget _buildArrow([double? size]) {
    if (widget.tileState.arrowDirection == ArrowDirection.none) {
      return const SizedBox.shrink();
    }

    final arrowSize = size ?? AppSizes.arrowSize;

    return Positioned(
      bottom: AppSizes.arrowPadding,
      right: widget.tileState.arrowDirection == ArrowDirection.right
          ? AppSizes.arrowPadding
          : null,
      left: widget.tileState.arrowDirection == ArrowDirection.left
          ? AppSizes.arrowPadding
          : null,
      child: Icon(
        widget.tileState.arrowDirection == ArrowDirection.left
            ? Icons.arrow_back
            : Icons.arrow_forward,
        color: Colors.white.withValues(alpha: 0.8),
        size: arrowSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _flipAnimation.value * 3.14159;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(angle);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Scale font size based on tile size
              final tileSize = constraints.maxWidth > 0
                  ? constraints.maxWidth
                  : AppSizes.tileSize;
              final fontSize =
                  (tileSize / AppSizes.tileSize) * AppSizes.tileFontSize;
              final arrowSize =
                  (tileSize / AppSizes.tileSize) * AppSizes.arrowSize;

              return Container(
                decoration: BoxDecoration(
                  color: angle > 3.14159 / 2
                      ? _getBackgroundColor()
                      : Colors.transparent,
                  border: Border.all(
                    color: _getBorderColor(),
                    width: AppSizes.tileBorderWidth,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppSizes.tileBorderRadius,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Transform(
                        transform: angle > 3.14159 / 2
                            ? (Matrix4.identity()..rotateX(3.14159))
                            : Matrix4.identity(),
                        alignment: Alignment.center,
                        child: Text(
                          widget.tileState.letter,
                          style: AppTextStyles.tileLetter.copyWith(
                            color: _getTextColor(),
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    ),
                    if (angle > 3.14159 / 2) _buildArrow(arrowSize),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

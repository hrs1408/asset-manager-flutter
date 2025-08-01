import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimatedCounter extends StatefulWidget {
  final double value;
  final Duration duration;
  final TextStyle? textStyle;
  final String? prefix;
  final String? suffix;
  final NumberFormat? formatter;
  final Curve curve;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 1000),
    this.textStyle,
    this.prefix,
    this.suffix,
    this.formatter,
    this.curve = Curves.easeOut,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: _previousValue,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.curve,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(
        begin: _previousValue,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: widget.curve,
      ));
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatValue(double value) {
    if (widget.formatter != null) {
      return widget.formatter!.format(value);
    }
    
    // Default Vietnamese currency formatting
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final formattedValue = _formatValue(_animation.value);
        return Text(
          '${widget.prefix ?? ''}$formattedValue${widget.suffix ?? ''}',
          style: widget.textStyle,
        );
      },
    );
  }
}

class AnimatedProgressBar extends StatefulWidget {
  final double value;
  final double maxValue;
  final Duration duration;
  final Color? backgroundColor;
  final Color? progressColor;
  final double height;
  final BorderRadius? borderRadius;
  final bool showPercentage;
  final TextStyle? percentageStyle;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    required this.maxValue,
    this.duration = const Duration(milliseconds: 800),
    this.backgroundColor,
    this.progressColor,
    this.height = 8,
    this.borderRadius,
    this.showPercentage = false,
    this.percentageStyle,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: (widget.value / widget.maxValue).clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || oldWidget.maxValue != widget.maxValue) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: (widget.value / widget.maxValue).clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ));
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? Colors.grey[300]!;
    final progressColor = widget.progressColor ?? theme.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(widget.height / 2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _animation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(widget.height / 2),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.showPercentage) ...[
          const SizedBox(height: 4),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final percentage = (_animation.value * 100).round();
              return Text(
                '$percentage%',
                style: widget.percentageStyle ?? 
                    TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
              );
            },
          ),
        ],
      ],
    );
  }
}
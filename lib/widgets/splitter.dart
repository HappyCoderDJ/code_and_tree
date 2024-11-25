import 'package:flutter/material.dart';

class Splitter extends StatefulWidget {
  final Widget firstChild;
  final Widget secondChild;
  final Axis axis;
  final double initialFirstFraction;
  final double minSizeFraction;
  final double maxSizeFraction;

  const Splitter({
    super.key,
    required this.firstChild,
    required this.secondChild,
    this.axis = Axis.vertical,
    this.initialFirstFraction = 0.5,
    this.minSizeFraction = 0.0,
    this.maxSizeFraction = 1.0,
  });

  @override
  State<Splitter> createState() => SplitterState();
}

class SplitterState extends State<Splitter> {
  late double _firstSize;

  @override
  void initState() {
    super.initState();
    _firstSize = 0.0;
  }

  void resetRatio() {
    setState(() {
      _firstSize = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double totalSize = widget.axis == Axis.vertical
          ? constraints.maxHeight
          : constraints.maxWidth;

      if (_firstSize == 0.0) {
        _firstSize = totalSize * widget.initialFirstFraction;
      }

      // Calculate min and max sizes based on fractions
      double minSize = totalSize * widget.minSizeFraction;
      double maxSize = totalSize * widget.maxSizeFraction;

      // Clamp _firstSize to min and max
      _firstSize = _firstSize.clamp(minSize, maxSize);

      return Flex(
        direction: widget.axis,
        children: [
          SizedBox(
            height: widget.axis == Axis.vertical ? _firstSize : null,
            width: widget.axis == Axis.horizontal ? _firstSize : null,
            child: widget.firstChild,
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanUpdate: (details) {
              setState(() {
                double delta = widget.axis == Axis.vertical
                    ? details.delta.dy
                    : details.delta.dx;
                _firstSize += delta;

                // Calculate min and max sizes based on fractions
                double minSize = totalSize * widget.minSizeFraction;
                double maxSize = totalSize * widget.maxSizeFraction;

                // Clamp _firstSize to min and max
                _firstSize = _firstSize.clamp(minSize, maxSize);
              });
            },
            child: SizedBox(
              width: widget.axis == Axis.vertical ? double.infinity : 8,
              height: widget.axis == Axis.vertical ? 8 : double.infinity,
              child: MouseRegion(
                cursor: widget.axis == Axis.vertical
                    ? SystemMouseCursors.resizeRow
                    : SystemMouseCursors.resizeColumn,
                child: widget.axis == Axis.vertical
                    ? const Divider(height: 1)
                    : const VerticalDivider(width: 1),
              ),
            ),
          ),
          Expanded(child: widget.secondChild),
        ],
      );
    });
  }
}

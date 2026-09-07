import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Two heaps side by side, with their counts on one line underneath.
///
/// A table rather than two columns glued together: a cloud of four is taller
/// than a cloud of two, so counts hung under each heap ended up at different
/// heights and stopped reading as a pair of numbers. Here the columns line up
/// because the grid makes them.
///
/// The separator repeats under the numbers - the plus between two heaps of
/// bees belongs between their counts too, because "2 + 4" is the very step
/// the pictures are there to prepare. Where the heaps are only compared there
/// is no plus to repeat, and the row underneath simply stays empty: writing
/// one in would teach an addition nobody asked for.
class CountedPair extends StatelessWidget {
  final Widget left;
  final Widget right;

  /// What goes between the two heaps: a plus, or a divider.
  final Widget separator;

  /// The same thing between the counts, where it means something. Null leaves
  /// the gap empty.
  ///
  /// Pass it plain, without a style: it is drawn in the style of the numbers
  /// it stands between. A plus half their size next to them looked like a
  /// mistake, and there is no reason it should ever differ.
  final Widget? countSeparator;

  /// Whether the separator is stretched to the height of the two heaps
  /// instead of being centred between them. The divider between two clouds
  /// has to grow with them - a stub of a line separates nothing.
  final bool stretchSeparator;

  /// The counts. Null on both means no second row at all.
  final int? leftCount;
  final int? rightCount;

  final double countSize;

  const CountedPair({
    super.key,
    required this.left,
    required this.right,
    required this.separator,
    this.countSeparator,
    this.stretchSeparator = false,
    this.leftCount,
    this.rightCount,
    this.countSize = 46,
    this.countColor = AppColors.text,
  });

  final Color countColor;

  @override
  Widget build(BuildContext context) {
    final showCounts = leftCount != null && rightCount != null;

    final numberStyle = TextStyle(
      fontSize: countSize,
      fontWeight: FontWeight.w700,
      color: countColor,
    );

    // Number and separator share the cell, so they share the offset too -
    // otherwise the plus sits half a padding higher than the digits.
    Widget countCell(Widget child) => Padding(
          padding: EdgeInsets.only(top: countSize * 0.16),
          child: Center(child: child),
        );

    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(children: [
          Center(child: left),
          if (stretchSeparator)
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.fill,
              child: separator,
            )
          else
            Center(child: separator),
          Center(child: right),
        ]),
        if (showCounts)
          TableRow(children: [
            countCell(Text('${leftCount!}',
                textAlign: TextAlign.center, style: numberStyle)),
            countCell(DefaultTextStyle.merge(
              style: numberStyle,
              child: countSeparator ?? const SizedBox.shrink(),
            )),
            countCell(Text('${rightCount!}',
                textAlign: TextAlign.center, style: numberStyle)),
          ]),
      ],
    );
  }
}

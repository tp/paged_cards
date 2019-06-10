import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CardPage extends StatefulWidget {
  const CardPage({
    Key key,
    @required this.color,
    @required this.isPrimaryCard,
    this.onScroll,
  }) : super(key: key);

  final Color color;

  final bool isPrimaryCard;

  /// Reports scroll offsett between 0 and 25
  final void Function(int offset) onScroll;

  @override
  _CardPageState createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final controller = ScrollController();

  int _lastReportedOffset = 0;

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      final currentOffset = controller.offset.round().clamp(0, 25);

      if (currentOffset != _lastReportedOffset) {
        _lastReportedOffset = currentOffset;

        setState(() {
          _lastReportedOffset = currentOffset;
        });

        if (widget.onScroll != null) {
          widget.onScroll(currentOffset);
        }
      }

      print('offset ${currentOffset}');
      // print('max ${controller.position?.maxScrollExtent}');
    });
  }

  void reportOffset(double offset) {
    final currentOffset = offset.round().clamp(0, 25);

    if (currentOffset != _lastReportedOffset) {
      _lastReportedOffset = currentOffset;

      print('reportOffset $currentOffset');

      setState(() {
        _lastReportedOffset = currentOffset;
      });

      if (widget.onScroll != null) {
        widget.onScroll(currentOffset);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _lastReportedOffset / 25;

//  SingleChildScrollView(
//       physics: widget.isPrimaryCard ? null : NeverScrollableScrollPhysics(),
//       controller: controller,
//       child: Container(
//         height: 1000,
//         child:
    return GestureDetector(
      onPanDown: (_) {
        print('pan down');
      },
      onPanUpdate: (x) {
        print('pan move ${-x.globalPosition.dy + 50}');

        reportOffset(-x.globalPosition.dy + 50);
      },
      child: Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 10 * (1 - progress),
          right: 10 * (1 - progress),
          bottom: 20,
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(
                10 * (1 - progress),
              ),
              topRight: Radius.circular(
                10 * (1 - progress),
              ),
            ),
            // This is just the child that'd be passed by the outside
            child: Scaffold(
                appBar: AppBar(
                  title: Text('Card'),
                ),
                body: ListView.builder(
                  itemCount: 1000,
                  itemBuilder: (context, index) {
                    // print('index $index');
                    return Container(
                      height: 30,
                      color: widget.color,
                      child: Text('$index'),
                    );
                  },
                )

                //  Container(
                //   // width: 100,
                //   // height: 100,

                // ),
                )),
        // ),
        // ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    controller.dispose();
  }
}

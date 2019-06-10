import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:paged_cards/paged_cards.dart';

class PagedCards extends StatefulWidget {
  const PagedCards({
    Key key,
    @required this.cardCount,
    @required this.builder,
  })  : assert(cardCount >= 0),
        assert(builder != null),
        super(key: key);

  final int cardCount;
  final Widget Function(BuildContext context, int index) builder;

  @override
  _PagedCardsState createState() => _PagedCardsState();
}

class _PagedCardsState extends State<PagedCards> {
  final PageController controller = PageController(
    viewportFraction: 0.9,
  );

  /// The vertical progress of the primary, centered card.
  /// Ranges from 0 (show smaller inline) to 1 (taking up the whole screen unscaled).
  double _centerCardProgress = 0;

  @override
  initState() {
    super.initState();

    controller.addListener(() {
      final currentPage = controller.hasClients &&
              // Enable workaround for a crasher on first render
              controller.position?.minScrollExtent != null
          ? controller.page.round()
          : null;

      if (currentPage != null && currentPage != _activePage) {
        setState(() {
          _activePage = currentPage;
          _currentCardOffset = 0;
          print('new active page = ${currentPage}');
        });
      }
    });

    Timer.periodic(Duration(milliseconds: 36), (d) {
      setState(() {
        // _centerCardProgress = (d.tick % 120 / 60).clamp(0.0, 1.0);
      });
    });
  }

  int _activePage = 0;
  int _currentCardOffset = 0;

  Widget _renderCard(
    BuildContext context, {
    int currentIndex,
    int centeredIndex,
  }) {
    final isCenteredCard = currentIndex == centeredIndex;
    final containerWidth = MediaQuery.of(context).size.width;
    final centeredCardWidthAfterScale = containerWidth *
        (0.9 + 0.1 * _centerCardProgress * _centerCardProgress);

    // positions
    double top = isCenteredCard ? 50 * (1 - _centerCardProgress) : 50;

    double singleSideLeftOver =
        (containerWidth - centeredCardWidthAfterScale) / 2;

    // print('singleSideLeftOver = $singleSideLeftOver');

    double left = isCenteredCard
        ? 0
        : (currentIndex < centeredIndex
            ? (-containerWidth +
                singleSideLeftOver +
                singleSideLeftOver *
                    (0.5 - _centerCardProgress * _centerCardProgress))
            : containerWidth -
                singleSideLeftOver -
                singleSideLeftOver *
                    (0.5 - _centerCardProgress * _centerCardProgress));

    //  (singleSideLeftOver / 4 +
    //     (currentIndex - centeredIndex) * centeredCardWidthAfterScale);

    // print(
    //   'index = $currentIndex, left = $left, containerWidth = $containerWidth',
    // );

    return Positioned(
      top: top,
      left: left,
      width: containerWidth,
      height: MediaQuery.of(context).size.height,
      // /   onPanDown: (_) {
      //     print('pan down');
      //   },
      //   onPanUpdate: (x) {
      //     print('pan move ${-x.globalPosition.dy + 50}');

      //     reportOffset(-x.globalPosition.dy + 50);
      //   },
      child: Container(
        // color: Colors.red,
        child: Transform.scale(
          // scale: 0.8,
          scale: 0.9 +
              (isCenteredCard
                  ? (0.1 * _centerCardProgress * _centerCardProgress)
                  : 0),
          // origin: Offset(-1, 0),
          child: GestureDetector(
            onPanDown: isCenteredCard
                ? (_) {
                    //     print('pan down');
                  }
                : null,
            onPanUpdate: isCenteredCard
                ? (x) {
                    print('pan move ${-x.globalPosition.dy + 50}');

                    //     reportOffset(-x.globalPosition.dy + 50);
                  }
                : null,
            child: CardPage(
              color: currentIndex % 2 == 0 ? Colors.red : Colors.blue,
              isPrimaryCard: isCenteredCard,
              onScroll: (offset) {
                setState(() {
                  _currentCardOffset = offset;
                  print('_currentCardOffset = $_currentCardOffset');
                });
              },
              builder: (context) => widget.builder(context, currentIndex),
              // current
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // print('_currentCardOffset = $_currentCardOffset');

    final selectedIndex = 1;

    return Stack(children: [
      _renderCard(context, currentIndex: 0, centeredIndex: selectedIndex),
      _renderCard(context, currentIndex: 2, centeredIndex: selectedIndex),
      _renderCard(context, currentIndex: 1, centeredIndex: selectedIndex),

      // Positioned(
      //   top: 50,
      //   left: -(MediaQuery.of(context).size.width - 100) + 40,
      //   width: MediaQuery.of(context).size.width - 100,
      //   height: MediaQuery.of(context).size.height,
      //   child: CardPage(
      //     color: 0 % 2 == 0 ? Colors.red : Colors.blue,
      //     isPrimaryCard: index == _activePage,
      //     onScroll: (offset) {
      //       setState(() {
      //         _currentCardOffset = offset;
      //         print('_currentCardOffset = $_currentCardOffset');
      //       });
      //     },
      //     builder: (context) => widget.builder(context, 0),
      //     // current
      //   ),
      // ),

      // Positioned(
      //   top: 50,
      //   left: MediaQuery.of(context).size.width - 50,
      //   width: MediaQuery.of(context).size.width - 100,
      //   height: MediaQuery.of(context).size.height,
      //   // right: -100,
      //   // bottom: 0,
      //   child: CardPage(
      //     color: 2 % 2 == 0 ? Colors.red : Colors.blue,
      //     isPrimaryCard: index == _activePage,
      //     onScroll: (offset) {
      //       setState(() {
      //         _currentCardOffset = offset;
      //         print('_currentCardOffset = $_currentCardOffset');
      //       });
      //     },
      //     builder: (context) => widget.builder(context, 2),
      //     // current
      //   ),
      // )
    ]);

    // controller.viewportFraction = 1;
    // TODO: ListView.custom ?
    // FixedExtentScrollPhysics
    // https://stackoverflow.com/questions/47349784/creating-image-carousel-in-flutter
    // return Transform.scale(
    //     scale: 0.9 + (_currentCardOffset / 25) * 0.25,
    //     child: PageView.builder(
    //       physics: const PageScrollPhysics(),

    //       controller: controller,

    //       // itemExtent: 370,
    //       itemBuilder: (context, index) {
    //         return Container(
    //           // width: 360,
    //           child: CardPage(
    //             color: index % 2 == 0 ? Colors.red : Colors.blue,
    //             isPrimaryCard: index == _activePage,
    //             onScroll: (offset) {
    //               setState(() {
    //                 _currentCardOffset = offset;
    //                 print('_currentCardOffset = $_currentCardOffset');
    //               });
    //             },
    //             // current
    //           ),
    //           height: 1000,
    //         );
    //       },
    //       itemCount: widget.cards.length,
    //       scrollDirection: Axis.horizontal,
    //     ));

    // return PageView.builder(
    //   controller: controller,
    //   itemBuilder: (context, index) {
    //     return Container(
    //       color: Colors.green,
    //       child: Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: CardPage(
    //           color: index % 2 == 0 ? Colors.red : Colors.blue,
    //           isPrimaryCard: index == _activePage,
    //           // current
    //         ),
    //       ),
    //     );
    //   },
    //   itemCount: widget.cards.length,
    // );
  }

  @override
  void dispose() {
    super.dispose();

    controller.dispose();
  }
}
